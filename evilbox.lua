
evilbox = {}

local density = 0.01
local imgPath = "gfx/characters/evilbox.png"

evilbox.acceleration = { air = 0, ground = 500 } -- TODO Use ?
evilbox.maxSpeed = 100

evilbox.state = "ground"
evilbox.onGround = true
evilbox.moveVector = { x = 0, y = 0 }
evilbox.blocked = { left = false, right = false }
evilbox.dazedTimer = 0

evilbox.rect = nil
evilbox.world = nil
evilbox.chasee = nil
evilbox.groundCallback = nil
evilbox.leftRightCallback = nil

function evilbox:wasHitCallback(fixture, x, y, xn, yn, fraction, other)
    if other.label == "player" then
        self.chasee = other
    end
end

function evilbox:getGroundCallback()
    local self = self
    local function callback(fixture, x, y, xn, yn, fraction)
        other = fixture:getUserData()
        if other == self or other.label == "player" then
            return -1
        end

        self.onGround = true
        -- Call "you were stomped" callback
        if other and other.wasHitCallback then
            other.wasHitCallback(other, fixture, x, y, xn, yn, fraction, self)
        end
        -- This should probably be in update instead, but meh
        local oldX, oldY = self.rect.body:getPosition()
        self.rect.body:setPosition(oldX, y - self.rect.height/2)
        return 0
    end
    return callback
end

function evilbox:getLeftRightCallback()
    local self = self
    local function callback(fixture, x, y, xn, yn, fraction)

        local function setToDazed()
            self.dazedTimer = love.timer.getTime() + 1 
        end

        other = fixture:getUserData()

        if other == self or other.label == "player" then
            return -1
        end

        -- Some of this should probably be in update instead, but meh
        local oldX, oldY = self.rect.body:getPosition()
        if x < oldX then
            if self.rect.body:getLinearVelocity() < -self.maxSpeed/2 then
                setToDazed()
                self.rect.body:setLinearVelocity(0, 0)
            end
            self.blocked.left = true
            self.rect.body:setPosition(x + self.rect.width/2, oldY)
        else
            if self.rect.body:getLinearVelocity() > self.maxSpeed/2 then
                setToDazed()
                self.rect.body:setLinearVelocity(0, 0)
            end
            self.blocked.right = true
            self.rect.body:setPosition(x - self.rect.width/2, oldY)
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
    self.state = "ground"
    self.onGround = true

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

function evilbox:update(dt)
    self.onGround = false
    self.blocked = { left = false, right = false }
    self.world:rayCast(self.rect:getX() - self.rect:getWidth()/2, self.rect:getY(), 
                       self.rect:getX() - self.rect:getWidth()/2, 
                       self.rect:getY() + self.rect:getHeight()/2 + 10, 
                       self.groundCallback)
    self.world:rayCast(self.rect:getX() + self.rect:getWidth()/2, self.rect:getY(), 
                       self.rect:getX() + self.rect:getWidth()/2, 
                       self.rect:getY() + self.rect:getHeight()/2 + 10, 
                       self.groundCallback)
    self.world:rayCast(self.rect:getX(), self.rect:getY(), 
                       self.rect:getX() + self.rect:getWidth()/2, self.rect:getY(), 
                       self.leftRightCallback)
    self.world:rayCast(self.rect:getX(), self.rect:getY(), 
                       self.rect:getX() - self.rect:getWidth()/2, self.rect:getY(), 
                       self.leftRightCallback)

    self.state = self.onGround and "ground" or "air"

    if self.state == "ground" and self.rect.body:getType() == "dynamic" then
        self.rect.body:setType("kinematic")
        self.rect.body:setLinearVelocity(0,0)
    elseif self.state ~= "ground" and self.rect.body:getType() == "kinematic" then
        self.rect.body:setType("dynamic")
    end

    if self.rect.body:getType() == "kinematic" 
        and love.timer.getTime() > self.dazedTimer 
        and self.onGround 
        and self.chasee then

        local othX = self.chasee:getX()
        local myX = self.rect.body:getX()

        if othX < myX then
            if not self.blocked.left then
                self.rect.body:setLinearVelocity(-self.maxSpeed, 0)
            end
        elseif othX > myX then
            if not self.blocked.right then
                self.rect.body:setLinearVelocity(self.maxSpeed, 0)
            end
        end
    else
        -- If we can't chase for some reason, stop chasing
        self.chasee = nil
    end
end

-- Mostly for debugging, handled by STI normally
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

