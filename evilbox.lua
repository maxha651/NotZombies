
anim8 = require "anim8/anim8"

evilbox = {}

local imgPath = "gfx/characters/evilbox.png"
local animImgPath = "gfx/characters/evileye-ani.png"

local maxSpeed = 100
local mass = 300
local topRaycastPadding = 3
local groundRaycastPadding = 3
local sideRaycastPadding = 3
local chasePadding = 0.5 -- % of player width
local stackTime = 0.3
local tileHeight = 70
local tileWidth = 70
local animDuration = 0.15
local blockedTimeout = 0.25
local angryTime = animDuration * 5
local dazedTime = angryTime
local chaseRangeX = 1000
local chaseRangeY = 500

evilbox.label = "evilbox"
evilbox.state = "ground"
evilbox.onGround = true
evilbox.moveVector = { x = 0, y = 0 }
evilbox.blocked = { left = false, right = false }
evilbox.other = { left = nil, right = nil }
evilbox.blockedTimer = 0
evilbox.dazedTimer = 0
evilbox.angryTimer = 0
evilbox.start = { x = 0, y = 0 }
evilbox.lastPosition = { x = 0, y = 0 }

evilbox.rect = nil
evilbox.circle = nil
evilbox.anim = {}
evilbox.world = nil
evilbox.chasee = nil
evilbox.topCallback = nil
evilbox.groundCallback = nil
evilbox.leftRightCallback = nil
evilbox.tmpstate = {}

function evilbox:playerStompCallback(other)
    if self.state == "idle" then
        self.chasee = other
        self.angryTimer = love.timer.getTime() + angryTime
    end
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

function evilbox:setAnim(mode)
    if self.anim[mode] and self.anim.current ~= mode then
        local oldFrame = self.anim[self.anim.current].position
        self.anim.current = mode
        self.anim[mode]:gotoFrame(6 - oldFrame)
        self.anim[mode]:resume()
    end
end

function evilbox:getAnim()
    return self.anim.current
end

-- Callbacks below are used for raycasting and should (I think, bad docs)
-- be able to be considered as part of the update loop

function evilbox:getTopCallback()
    local self = self
    local function callback(fixture, x, y, xn, yn, fraction)
        other = fixture:getUserData()

        if other == self then
            return -1
        end

        -- TODO HACK
        if other.label == "evilbox" and other.rect.fixture:getMask() == evilboxCollisionMask then
            return -1
        end

        if other.label == "evilbox" then
            if self.other.top ~= other then
                -- Stop on first detect
                self:setVelocity(0,0)
            end
            self.tmpstate.other.top = other
            self.state = "topControlled"
            self.chasee = nil
        end
        return 0
    end
    return callback
end

function evilbox:getGroundCallback()
    local self = self
    local function callback(fixture, x, y, xn, yn, fraction)
        other = fixture:getUserData()

        if other == self or other.label == "player" or other.label == "checkpoint" then
            return -1
        end

        self.tmpstate.onGround = true
        local oldX, oldY = self.rect.body:getPosition()
        if oldY ~= y - self.rect:getHeight()/2 then
            self.rect.body:setPosition(oldX, y - self.rect:getHeight()/2)
            self.rect.body:setLinearVelocity(self.rect.body:getLinearVelocity(), 0)
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

        if other == self or other.label == "player" or other.label == "checkpoint" then
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
                --other:startStacking() Disabled for now
                return -1
            end
            if not self.stopping then
                self.dazedTimer = love.timer.getTime() + dazedTime
            end
        end

        if relativeVelocityX > 0 then
            local _, oldVelY = self.rect.body:getLinearVelocity()
            self.rect.body:setLinearVelocity(0, oldVelY)
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
    self.rect.body:setMass(mass)
    self.rect.body:setFixedRotation(true)
    self.rect.body:setLinearVelocity(0, 0)
    self.rect.fixture:setUserData(self)
    self.rect.fixture:setCategory(evilboxCollisionMask)

    self.circle = love.filesystem.load("circle.lua")()
    self.circle:load(world, x, y, width/2 - 2)
    self.circle.fixture:setRestitution(0.0) -- bounce
    self.circle.body:setSleepingAllowed(false)
    self.circle.body:setMass(mass) -- Apparently doesn't mean shit, set on enable
    self.circle.body:setFixedRotation(true)
    self.circle.fixture:setUserData(self)
    self.circle.fixture:setCategory(evilboxCollisionMask)
    self.circle:setEnabled(false)

    self.anim.img = love.graphics.newImage(animImgPath)
    self.anim.grid = anim8.newGrid(tileWidth, tileHeight, self.anim.img:getWidth(), 
                                   self.anim.img:getHeight(), 10, 10) -- margins
    self.anim["sleep"] = anim8.newAnimation(self.anim.grid("5-1",1), animDuration, "pauseAtEnd")
    self.anim["awake"] = anim8.newAnimation(self.anim.grid("1-5",1), animDuration, "pauseAtEnd")
    self.anim.current = "sleep"
    self.anim[self.anim.current]:pauseAtEnd()

    self.topCallback = self:getTopCallback()
    self.groundCallback = self:getGroundCallback()
    self.leftRightCallback = self:getLeftRightCallback()
end

function evilbox:reload()
    self.state = "idle"
    self.onGround = true
    self.chasee = nil
    self.rect:setEnabled(true)
    self.rect.body:setLinearVelocity(0,0)
    self.rect.body:setPosition(self.start.x, self.start.y)
    self.anim.current = "sleep"
    self.anim[self.anim.current]:pauseAtEnd()
end

function evilbox:update(dt)
    if self.updateOverride then
        self:updateOverride(dt)
        return
    end

    -- update some status values by raycasting
    local function updateRaycast()
        -- Use temporary values to still have access to old ones
        self.tmpstate.onGround = false
        self.tmpstate.blocked = { left = false, right = false }
        self.tmpstate.other = {}
        if not self.circle:getEnabled() then
            local x, y = self.rect:getX(), self.rect:getY()

            self.world:rayCast(x - self.rect:getWidth()/2, y, 
                               x - (self.rect:getWidth()/2 - sideRaycastPadding), 
                               y - (self.rect:getHeight()/2 + topRaycastPadding), 
                               self.topCallback)
            self.world:rayCast(x + self.rect:getWidth()/2, y, 
                               x + (self.rect:getWidth()/2 - sideRaycastPadding), 
                               y - (self.rect:getHeight()/2 + topRaycastPadding), 
                               self.topCallback)
            if not self.onGround then
                -- Just so we don't get quick/bad onGround/not onGround switching
                self.world:rayCast(x, y, x, y + self.rect:getHeight()/2 + groundRaycastPadding, 
                                   self.groundCallback)
            else
                self.world:rayCast(x - self.rect:getWidth()/2, y, 
                                   x - (self.rect:getWidth()/2 - sideRaycastPadding), 
                                   y + self.rect:getHeight()/2 + groundRaycastPadding, 
                                   self.groundCallback)
                self.world:rayCast(x + self.rect:getWidth()/2, y, 
                                   x + (self.rect:getWidth()/2 - sideRaycastPadding), 
                                   y + self.rect:getHeight()/2 + groundRaycastPadding, 
                                   self.groundCallback)
            end
            self.world:rayCast(x, y, 
                               x + (self.rect:getWidth()/2 + sideRaycastPadding), 
                               y, self.leftRightCallback)
            self.world:rayCast(x, y, x - (self.rect:getWidth()/2 + sideRaycastPadding), y, 
                               self.leftRightCallback)
        else
            local x, y = self.circle:getX(), self.circle:getY()
            -- We only care whether we're on ground or not
            self.world:rayCast(x, y, x,y + self.rect:getHeight()/2 + groundRaycastPadding, 
                               self.groundCallback)
        end
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
    end

    local function updatePhysics() 
        --[[
        if self.onGround and self.circle:getEnabled() then
            self.circle:setEnabled(false)
            self.rect.body:setMass(mass) -- Needed for circle, not sure here
            self.rect.body:setPosition(self.circle:getX(), self.circle:getY())
            self.rect.body:setLinearVelocity(0,0)
        elseif not self.onGround and not self.circle:getEnabled() then
            self.circle:setEnabled(true)
            self.circle.fixture:setMask(evilboxCollisionMask);
            self.circle.body:setMass(mass) -- I shouldn't have to do this...
            self.circle.body:setPosition(self.rect:getX(), self.rect:getY())
            self.circle.body:setLinearVelocity(0,0)
        end
        --]]

        if self.circle:getEnabled() then
            self.rect.body:setPosition(self.circle:getX(), self.circle:getY())
        end

        -- Check if chasee out of range
        if self.chasee and 
            (math.abs(self.chasee:getX() - self.rect:getX()) > chaseRangeX or
             math.abs(self.chasee:getY() - self.rect:getY()) > chaseRangeY) then
            self.chasee = nil
        end

        -- Can't stop gravity, keep first. But this loop is stupid
        if not self.onGround then
            self.state = "falling"
            self.chasee = nil

            local _, oldVelY = self.rect.body:getLinearVelocity()
            self.rect.body:setLinearVelocity(0, oldVelY + dt * 9.82 * oneMeter)
            self.stopping = false -- Will be weird if this does stuff while falling
            -- First check if incapacitated
        elseif love.timer.getTime() < self.dazedTimer then 
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
            if othX < myX - self.rect:getWidth() * chasePadding then
                self.state = "chasing"
                if self.blocked.left then
                    if self.blockedTimer == 0 then
                        self.blockedTimer = love.timer.getTime() + blockedTimeout
                    elseif love.timer.getTime() > self.blockedTimer then
                        self.blockedTimer = 0 -- reset
                        self.chasee = nil
                    end
                else
                    self.blockedTimer = 0
                    -- We have a target and isn't blocked, chase!
                    self:setVelocity(-maxSpeed, 0)
                end

                -- Player is to the right of us + padding
            elseif othX > myX + self.rect:getWidth() * chasePadding then
                self.state = "chasing"
                if self.blocked.right then
                    if self.blockedTimer == 0 then
                        self.blockedTimer = love.timer.getTime() + blockedTimeout
                    elseif love.timer.getTime() > self.blockedTimer then
                        self.blockedTimer = 0 -- reset
                        self.chasee = nil
                    end
                else
                    -- We have a target and isn't blocked, chase!
                    self:setVelocity(maxSpeed, 0)
                end

                -- Player is on top of us, we don't like that
            elseif self.state ~= "angry" then
                self.blockedTimer = 0 -- reset
                self.state = "angry"
                self:setVelocity(0, 0)
            end
        else
            -- onGround and not self.chasee (I hope/think)
            -- Keep same speed here (we want it to keep moving even if it's 
            -- lost track of player
            self.state = "idle"
            -- Just to be sure
            self.chasee = nil
        end
    end

    local function updateStopVelocity()
        local oldVelX, oldVelY = self.rect.body:getLinearVelocity()
        if self.stopping then
            if oldVelX < 0 and self.blocked.left or
                oldVelX > 0 and self.blocked.right then
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
                self.rect.body:setLinearVelocity(0, oldVelY)
                -- Setting proper pos done in raycast instead... 
                --self.rect.body:setPosition((currX + (width - currX % width)) - width/2, 
                --                           self.rect.body:getY())
                self.stopping = false
            end
            if math.abs(currX % width) < width*0.25 and math.abs(lastX % width) > width*0.75 then
                self.rect.body:setLinearVelocity(0, oldVelY)
                --self.rect.body:setPosition((currX - currX % width) - width/2, 
                --                           self.rect.body:getY())
                self.stopping = false
            end
        end

        self.lastPosition.x = self.rect.body:getX()
    end

    -- Doesn't control Y right now since I like the effect it gives i.e. funky
    -- falling
    local function updateTopControlled()
        local diffX = self.other.top:getX() - self.rect:getX()
        local otherVelX = self.other.top.rect.body:getLinearVelocity()
        if (diffX * otherVelX > 0) and (diffX > 0 and not self.blocked.right or
                                        diffX < 0 and not self.blocked.left) then
            --self.rect.body:setPosition(self.other.top:getX(), self.rect:getY())
            self.rect.body:setLinearVelocity(otherVelX, 0)
        elseif diffX * self.rect.body:getLinearVelocity() < 0 then
            -- Stop immediately if we're moving away from controller
            self.rect.body:setLinearVelocity(0,0)
        elseif diffX * self.rect.body:getLinearVelocity() > 0 then
            -- Otherwise stop smoothly
            self:setVelocity(0,0)
        end
    end

    local function updateAnimation()
        -- mimic controller if exists
        if self.other.top then
            self:setAnim(self.other.top:getAnim())
        -- Awake if chasing
        elseif self.chasee then
            self:setAnim("awake")
        -- Otherwise sleep
        elseif not self.chasee then
            self:setAnim("sleep")
        end
        self.anim[self.anim.current]:update(dt)
    end

    updateRaycast()
    updateState()
    if self.other.top and self.onGround then
        updateTopControlled()
    else
        updatePhysics()
        updateStopVelocity()
    end
    updateAnimation()
end

function evilbox:setVelocity(x, y)
    local oldX = self.rect.body:getLinearVelocity()
    if x == 0 and oldX ~= 0 then
        self.stopping = true
        self.rect.body:setLinearVelocity(oldX, y)
    else
        self.rect.body:setLinearVelocity(x, y)
    end
    -- TODO self.velocityToReach = { x = x, y = y }
end

function evilbox:draw()
    if self.circle:getEnabled() then
        self.anim[self.anim.current]:draw(self.anim.img, 
                                          self.circle:getX() - self.circle:getRadius(), 
                                          self.circle:getY() - self.circle:getRadius())
    else
        self.anim[self.anim.current]:draw(self.anim.img, 
                                          self.rect:getX() - self.rect:getWidth()/2, 
                                          self.rect:getY() - self.rect:getHeight()/2)
    end
    self.rect:draw()
    self.circle:draw()
end

function evilbox:getX()
    return self.rect:getX()
end

function evilbox:getY()
    return self.rect:getY()
end

return evilbox

