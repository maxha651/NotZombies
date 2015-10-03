
evilbox = {}

local imgPath = "gfx/characters/evilbox.png"

local maxSpeed = 100
local density = 0.1
local dazedTime = 1
local angryTime = 1
local topRaycastPadding = 3
local groundRaycastPadding = 5
local sideRaycastPadding = 3
local chasePadding = 0.1 -- % of player width
local stackTime = 0.3
local tileHeight = 70
local tileWidth = 70

evilbox.label = "evilbox"
evilbox.state = "ground"
evilbox.onGround = true
evilbox.moveVector = { x = 0, y = 0 }
evilbox.blocked = { left = false, right = false }
evilbox.other = { left = nil, right = nil }
evilbox.dazedTimer = 0
evilbox.angryTimer = 0
evilbox.start = { x = 0, y = 0 }
evilbox.lastPosition = { x = 0, y = 0 }

evilbox.rect = nil
evilbox.world = nil
evilbox.chasee = nil
evilbox.topCallback = nil
evilbox.groundCallback = nil
evilbox.leftRightCallback = nil
evilbox.tmpstate = {}

function evilbox:playerStompCallback(other)
    self.chasee = other
    self.angryTimer = love.timer.getTime() + angryTime
end

function evilbox:startStacking()
    self.updateOverride = self.stackUpdate
    self.stackStart = self.rect:getY()
    self.stackEnd = self.rect:getY() - tileHeight
    self.startStackTime = love.timer.getTime()
    self.currentStackTime = self.startStackTime
    -- Ignore collisions from other boxes during stack
    self.rect.fixture:setMask(evilboxCollisionMask)
end

function evilbox:stackUpdate(dt)
    self.currentStackTime = self.currentStackTime + dt
    local lerp = (self.currentStackTime - self.startStackTime) / stackTime
    if lerp >= 1 then
        self.rect.body:setPosition(self.rect:getX(), self.stackEnd)
        self.rect.fixture:setMask()
        self.updateOverride = nil
    else
        self.rect.body:setPosition(self.rect:getX(), self.stackStart * (1 - lerp)
                                  + self.stackEnd * lerp)
    end
end

-- Callbacks below are used for raycasting and should (I think, bad docs)
-- be able to be considered as part of the update loop

function evilbox:getTopCallback()
    local self = self
    local function callback(fixture, x, y, xn, yn, fraction)
        other = fixture:getUserData()

        -- Only update if topcontroller has left or another at top
        if other.label == "evilbox" and self.other.top ~= other then
            self.tmpstate.other.top = other
            self.rect.body:setLinearVelocity(0,0)
            self.state = "topControlled"
        end
        return 0
    end
    return callback
end

function evilbox:getGroundCallback()
    local self = self
    local function callback(fixture, x, y, xn, yn, fraction)
        other = fixture:getUserData()

        if other == self or other.label == "player" then
            return -1
        end

        self.tmpstate.onGround = true
        local oldX, oldY = self.rect.body:getPosition()
        if oldY ~= y - self.rect:getHeight()/2 then
            self.rect.body:setPosition(oldX, y - self.rect:getHeight()/2)
        end
        return 0
    end
    return callback
end

-- Will return -1 if collision is to be ignored, update state as late as 
-- possible so we don't get some trash state on collision ignore
function evilbox:getLeftRightCallback()
    local self = self
    local function callback(fixture, x, y, xn, yn, fraction)

        local other = fixture:getUserData()

        if other == self or other.label == "player" then
            return -1
        end

        -- TODO HACK
        if other.label == "evilbox" and other.rect.fixture:getMask() == evilboxCollisionMask then
            return -1
        end

        local oldX, oldY = self.rect.body:getPosition()
        local dir = x < oldX and -1 or 1
        local dirString = x < oldX and "left" or "right"
        local otherVelocityX = 0

        if other.label == "evilbox" then
            -- Check relative velocity if another box
            otherVelocityX = other.rect.body:getLinearVelocity()
        end

        local relativeVelocityX = dir * (self.rect.body:getLinearVelocity() - otherVelocityX)

        if relativeVelocityX > maxSpeed/2 then
            -- SPECIAL STACK CASE
            if other.startStacking and other.blocked[dirString] and 
                self.other[dirString == "left" and "right" or "left"] then
                --self.other[dirString == "left" and "right" or "left"] then
                -- if two boxes (or more) crash into another (still) one,
                -- then stack the crashee. This collision should be ignored
                other:startStacking()
                return -1
            end
            self.dazedTimer = love.timer.getTime() + dazedTime
        end

        if relativeVelocityX > 0 then
            self.rect.body:setLinearVelocity(0,0)
            self.rect.body:setPosition(x - dir * (self.rect:getWidth()/2), oldY)
        end

        -- Update nearby thing reference
        self.tmpstate.blocked[dirString] = true
        self.tmpstate.other[dirString] = other

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
    self.rect.fixture:setCategory(evilboxCollisionMask)

    self.topCallback = self:getTopCallback()
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
    if self.updateOverride then
        self:updateOverride(dt)
        return
    end

    local function updateRaycast()
        -- Use temporary values to still have access to old ones
        self.tmpstate.onGround = false
        self.tmpstate.blocked = { left = false, right = false }
        self.tmpstate.other = {}
        -- update some status values (and other stuff)
        self.world:rayCast(self.rect:getX(), self.rect:getY(), 
                           self.rect:getX(), self.rect:getY() - (self.rect:getHeight()/2 
                                                                 + topRaycastPadding), 
                           self.topCallback)
        self.world:rayCast(self.rect:getX() - self.rect:getWidth()/2, self.rect:getY(), 
                           self.rect:getX() - (self.rect:getWidth()/2 - sideRaycastPadding), 
                           self.rect:getY() + self.rect:getHeight()/2 + groundRaycastPadding, 
                           self.groundCallback)
        self.world:rayCast(self.rect:getX() + self.rect:getWidth()/2, self.rect:getY(), 
                           self.rect:getX() + (self.rect:getWidth()/2 - sideRaycastPadding), 
                           self.rect:getY() + self.rect:getHeight()/2 + groundRaycastPadding, 
                           self.groundCallback)
        self.world:rayCast(self.rect:getX(), self.rect:getY(), 
                           self.rect:getX() + (self.rect:getWidth()/2 + sideRaycastPadding), 
                           self.rect:getY(), self.leftRightCallback)
        self.world:rayCast(self.rect:getX(), self.rect:getY(), 
                           self.rect:getX() - (self.rect:getWidth()/2 + sideRaycastPadding), 
                           self.rect:getY(), self.leftRightCallback)
    end

    local function updateState()
        local key, val
        -- The nearbe object check needs to be a bit more persistent
        for key, val in pairs(self.other) do
            -- Only check for left-right (top is trouble). Getting ugly
            if key == "left" or key == "right" then
                if val.getX and val:getX() < self.rect:getX() + 1.5*self.rect:getWidth()
                    and val:getX() > self.rect:getX() - 1.5*self.rect:getWidth() then
                    -- Save old nearby object
                    self.tmpstate.other[key] = val
                end
            end
        end
        -- Update to new values
        for key, val in pairs(self.tmpstate) do
            self[key] = val
        end

        -- Update state string
        self.state = self.onGround and "ground" or "air"
    end

    local function updatePhysics()

        if self.onGround and self.rect.body:getType() ~= "kinematic" then
            self.rect.body:setType("kinematic")
            self:setVelocity(0,0)
        elseif not self.onGround and self.rect.body:getType() ~= "dynamic" then
            self.rect.body:setType("dynamic")
        end

        -- First check if incapacitated
        if love.timer.getTime() < self.dazedTimer then 
            self.state = "dazed"
            -- Forget about chasing
            self.chasee = nil
            self:setVelocity(0,0) -- not really needed

            -- Or initally angry which should be very similar (make same?)
        elseif love.timer.getTime() < self.angryTimer then
            self.state = "angry"
            self:setVelocity(0,0)

            -- Then check if we want to chase someone/something
        elseif self.onGround and self.chasee then

            local othX = self.chasee:getX()
            local myX = self.rect.body:getX()

            -- Player is to the left of us - padding
            if othX < myX - rect:getWidth() * chasePadding 
                and not self.blocked.left then
                self.state = "chasing"
                self:setVelocity(-maxSpeed, 0)

                -- Player is to the right of us + padding
            elseif othX > myX + rect:getWidth() * chasePadding 
                and not self.blocked.right then
                self.state = "chasing"
                self:setVelocity(maxSpeed, 0)

                -- Player is on top of us, we don't like that
            elseif self.state ~= "angry" then
                self:setVelocity(0, 0)
                self.state = "angry"

            end
            -- Otherwise, idle
        else
            self.state = "idle"
            -- Just to be sure
            self.chasee = nil
        end
    end

    local function updateStopVelocity()
        if self.stopping then
            if self.rect.body:getLinearVelocity() < 0 and self.blocked.left or
                self.rect.body:getLinearVelocity() > 0 and self.blocked.right then
                -- We are blocked, stop immediately
                self.stopping = false
                return
            end

            local currX, lastX = self.rect:getX(), self.lastPosition.x
            local width = self.rect:getWidth()
            -- Align box side to tile width
            currX = currX + width / 2
            lastX = lastX + width / 2
            if math.abs(currX % width) > width*0.75 and math.abs(lastX % width) < width*0.25 then
                self.rect.body:setLinearVelocity(0, 0)
                -- Setting proper pos done in raycast instead... 
                --self.rect.body:setPosition((currX + (width - currX % width)) - width/2, 
                --                           self.rect.body:getY())
                self.stopping = false
            end
            if math.abs(currX % width) < width*0.25 and math.abs(lastX % width) > width*0.75 then
                self.rect.body:setLinearVelocity(0, 0)
                --self.rect.body:setPosition((currX - currX % width) - width/2, 
                --                           self.rect.body:getY())
                self.stopping = false
            end
        end

        self.lastPosition.x = self.rect.body:getX()
    end

    local function updateTopControlled()
        local velocityX = self.other.top:getX() - self.rect:getX()
        if velocityX > 0 and not self.blocked.right or
            velocityX < 0 and not self.blocked.left then
            self.rect.body:setPosition(self.other.top:getX(), self.rect:getY())
        end
    end

    updateRaycast()
    updateState()
    if self.other.top then
        updateTopControlled()
    else
        updatePhysics()
        updateStopVelocity()
    end
end

function evilbox:setVelocity(x, y)
    if x == 0 and self.rect.body:getLinearVelocity() ~= 0 then
        self.stopping = true
    else
        self.rect.body:setLinearVelocity(x, y)
    end
    -- TODO self.velocityToReach = { x = x, y = y }
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

