
evilbox = {}

local imgPath = "gfx/characters/evilbox.png"

local maxSpeed = 100
local density = 0.1
local dazedTime = 1
local angryTime = 1
local groundRaycastPadding = 3
local sideRaycastPadding = 3
local chasePadding = 0.1 -- % of player width

evilbox.label = "evilbox"
evilbox.state = "ground"
evilbox.onGround = true
evilbox.moveVector = { x = 0, y = 0 }
evilbox.blocked = { left = false, right = false }
evilbox.other = { left = nil, right = nil }
evilbox.dazedTimer = 0
evilbox.angryTimer = 0
evilbox.start = { x = 0, y = 0 }
evilbox.collisionForce = 0

evilbox.rect = nil
evilbox.world = nil
evilbox.chasee = nil
evilbox.groundCallback = nil
evilbox.leftRightCallback = nil

function evilbox:playerStompCallback(other)
    self.chasee = other
    self.angryTimer = love.timer.getTime() + angryTime
end

-- Callbacks below are used for raycasting and should (I think, bad docs)
-- be able to be considered as part of the update loop

function evilbox:getGroundCallback()
    local self = self
    local function callback(fixture, x, y, xn, yn, fraction)
        other = fixture:getUserData()
        -- Call "you were stomped" callback
        if other and other.wasHitCallback then
            other.wasHitCallback(other, fixture, x, y, xn, yn, fraction, self)
        end

        if other == self or other.label == "player" then
            return -1
        end

        self.onGround = true
        local oldX, oldY = self.rect.body:getPosition()
        self.rect.body:setPosition(oldX, y - self.rect.height/2)
        return 0
    end
    return callback
end

function evilbox:getLeftRightCallback()
    local self = self
    local function callback(fixture, x, y, xn, yn, fraction)

        other = fixture:getUserData()

        if other == self or other.label == "player" then
            return -1
        end

        local oldX, oldY = self.rect.body:getPosition()
        local dir = x < oldX and -1 or 1
        local dirString = x < oldX and "left" or "right"
        local otherVelocityX = 0

        self.blocked[dirString] = true;

        if other.label == "evilbox" then
            -- Update nearby box reference
            self.other[dirString] = other
            -- Check relative velocity if another box
            otherVelocityX = other.rect.body:getLinearVelocity()
        end

        local relativeVelocityX = dir * (self.rect.body:getLinearVelocity() - otherVelocityX)

        if relativeVelocityX > maxSpeed/2 then
            self.dazedTimer = love.timer.getTime() + dazedTime
        end
        if relativeVelocityX > 0 then
            self.rect.body:setLinearVelocity(0,0)
            self.rect.body:setPosition(x - dir * self.rect:getWidth()/2, oldY)
        end

        return 0
    end
    return callback
end


function evilbox:print()
    print("--- evilbox info: ---")
    print("state:\t", self.state)
    print("position: ", self.rect:getX(), self.rect:getY())
    print("moveVector: ", self.moveVector.x, self.moveVector.y)
    print()
end

function evilbox:load(world, x, y, width, height)
    self.world = world
    self.state = "idle"
    self.onGround = true
    self.start.x, self.start.y = x, y

    self.rect = love.filesystem.load("rect.lua")()
    self.rect:load(world, x, y, width, height, imgPath)

    self.rect.body:setType("kinematic")
    self.rect.fixture:setRestitution(0.0) -- bounce
    self.rect.body:setSleepingAllowed(false)
    self.rect.body:setMass(width*height*density)
    self.rect.body:setFixedRotation(true)
    self.rect.body:setLinearVelocity(0, 0)
    self.rect.fixture:setUserData(self)

    self.groundCallback = self:getGroundCallback()
    self.leftRightCallback = self:getLeftRightCallback()
end

function evilbox:reload()
    self.state = "idle"
    self.onGround = true
    self.chasee = nil
    self.rect.body:setType("kinematic")
    self.rect.body:setLinearVelocity(0,0)
    self.rect.body:setPosition(self.start.x, self.start.y)
end

function evilbox:update(dt)
    -- reset some status values
    self.onGround = false
    self.blocked = { left = false, right = false }
    self.boxLeft, self.boxRight = nil, nil
    -- update some status values (and other stuff)
    self.world:rayCast(self.rect:getX() - self.rect:getWidth()/2, self.rect:getY(), 
                       self.rect:getX() - self.rect:getWidth()/2, 
                       self.rect:getY() + self.rect:getHeight()/2 + groundRaycastPadding, 
                       self.groundCallback)
    self.world:rayCast(self.rect:getX() + self.rect:getWidth()/2, self.rect:getY(), 
                       self.rect:getX() + self.rect:getWidth()/2, 
                       self.rect:getY() + self.rect:getHeight()/2 + groundRaycastPadding, 
                       self.groundCallback)
    self.world:rayCast(self.rect:getX(), self.rect:getY(), 
                       self.rect:getX() + (self.rect:getWidth()/2 + sideRaycastPadding), 
                       self.rect:getY(), self.leftRightCallback)
    self.world:rayCast(self.rect:getX(), self.rect:getY(), 
                       self.rect:getX() - (self.rect:getWidth()/2 + sideRaycastPadding), 
                       self.rect:getY(), self.leftRightCallback)

    self.state = self.onGround and "ground" or "air"

    if self.onGround and self.rect.body:getType() ~= "kinematic" then
        self.rect.body:setType("kinematic")
        self.rect.body:setLinearVelocity(0,0)
    elseif not self.onGround and self.rect.body:getType() ~= "dynamic" then
        self.rect.body:setType("dynamic")
    end

    -- First check if incapacitated
    if love.timer.getTime() < self.dazedTimer then 
        self.state = "dazed"
        -- Forget about chasing
        self.chasee = nil
        self.rect.body:setLinearVelocity(0,0) -- not really needed

    -- Or initally angry which should be very similar (make same?)
    elseif love.timer.getTime() < self.angryTimer then
        self.state = "angry"
        self.rect.body:setLinearVelocity(0,0)

    -- Then check if we want to chase someone/something
    elseif self.onGround and self.chasee then

        local othX = self.chasee:getX()
        local myX = self.rect.body:getX()

        -- Player is to the left of us - padding
        if othX < myX - rect:getWidth() * chasePadding 
            and not self.blocked.left then
            self.state = "chasing"
            self.rect.body:setLinearVelocity(-maxSpeed, 0)

        -- Player is to the right of us + padding
        elseif othX > myX + rect:getWidth() * chasePadding 
            and not self.blocked.right then
            self.state = "chasing"
            self.rect.body:setLinearVelocity(maxSpeed, 0)

        -- Player is on top of us, we don't like that
        elseif self.state ~= "angry" then
            self.rect.body:setLinearVelocity(0, 0)
            self.state = "angry"

        end
    -- Otherwise, idle
    else
        self.state = "idle"
        -- Just to be sure
        self.chasee = nil
    end
end

function evilbox:draw()
    self.rect:draw()
end

function evilbox:getX()
    return self.rect:getX()
end

function evilbox:getY()
    return self.rect:getY()
end

return evilbox

