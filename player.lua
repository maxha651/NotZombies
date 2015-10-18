
love.filesystem.load("input.lua")()

player = {}

local playerStart = { x = 2500, y = 1400 }
local radius = 20
local mass = 25
local imgPath = "gfx/characters/player.png"
local yOfDeath = 5000
local minJump = 1
local jumpExp = 6
local jumpForce = 75000
local jumpMemory = 0.075

player.label = "player"

player.acceleration = { air = 15000, ground = 20000 }
player.maxSpeed = 200
player.jumpPoolMax = 1
player.friction = { air = 0.1, ground = 500 }
player.floorSpeed = 0.005
player.start = { x = playerStart.x, y = playerStart.y }

player.state = "ground"
player.onGround = false
player.moveVector = { x = 0, y = 0 }
player.jumpPool = player.jumpPoolMax
player.lastJump = -math.huge
player.blocked = { left = false, right = false }

player.circle = nil
player.world = nil
player.checkpoint = nil
player.groundCallback = nil
player.leftRightCallback = nil
player.topCallback = nil

-- Callbacks below are used for raycasting and should (I think, bad docs)
-- be able to be considered as part of the update loop

function player:getGroundCallback()
    local self = self
    local function groundHitCallback(fixture, x, y, xn, yn, fraction)
        other = fixture:getUserData()
        if other == self or other.label == "checkpoint" then
            return -1
        end

        self.onGround = true
        -- Call "you were stomped" callback
        if other and other.playerStompCallback then
            other.playerStompCallback(other, self)
        end
        return 0
    end
    return groundHitCallback
end

function player:getLeftRightCallback()
    local self = self
    local function callback(fixture, x, y, xn, yn, fraction)

        other = fixture:getUserData()
        if other == self then
            return -1
        end

        local oldX, oldY = self.circle.body:getPosition()
        if x < oldX then
            self.blocked.left = true
        else
            self.blocked.right = true
        end

        return 0
    end
    return callback
end

function player:getTopCallback()
    local self = self
    local function callback(fixture, x, y, xn, yn, fraction)
        other = fixture:getUserData()
        if other.label == "evilbox" then
            print("DEATHSTOMP")
            self:dead()
            return 0
        else
            return -1
        end
    end
    return callback
end

function player:print()
    print("--- Player info: ---")
    print("state:\t", self.state)
    print("position: ", self.circle:getX(), self.circle:getY())
    print("moveVector: ", self.moveVector.x, self.moveVector.y)
    print()
end

function player:dead()
    love.event.push("reload")
end

function player:load(world)
    self.world = world

    self.circle = love.filesystem.load("circle.lua")()
    self.circle:load(world, playerStart.x, playerStart.y, radius, imgPath)

    self.circle.fixture:setRestitution(0) -- bounce
    self.circle.body:setSleepingAllowed(false)
    self.circle.body:setMass(mass)
    self.circle.fixture:setUserData(self)
    self.circle.fixture:setCategory(playerCollisionMask)

    self.groundCallback = self:getGroundCallback()
    self.leftRightCallback = self:getLeftRightCallback()
    self.topCallback = self:getTopCallback()
end

function player:reload()
    self.moveVector = { x = 0, y = 0}
    if self.checkpoint ~= nil then
        self.circle.body:setPosition(self.checkpoint.x, self.checkpoint.y)
    else
        self.circle.body:setPosition(self.start.x, self.start.y)
    end
    self.circle.body:setLinearVelocity(0,0)
    self.circle.body:setAngle(0)
    self.circle.body:setAngularVelocity(0)
end

function player:update(dt)
    if self.circle:getY() > yOfDeath then
        print("FLY YOU FOOLS")
        self:dead()
    end

    local jump = input.getJump()
    if jump then
        self.lastJump = love.timer.getTime()
    elseif self.jumpPool == self.jumpPoolMax and 
        love.timer.getTime() - self.lastJump < jumpMemory then
        jump = true
    end

    if jump ~= self.jump and
        -- Make sure we jump a minimum distance
        (self.jumpPool == self.jumpPoolMax or self.jumpPool < self.jumpPoolMax * (1-minJump)) then
        self.jumpPool = self.jumpPoolMax
        self.jump = jump
    end
    self.moveVector.x = input.getXAxis()
    self.moveVector.y = input.getYAxis()

    self.onGround = false
    self.blocked = { left = false, right = false }
    self.world:rayCast(self.circle:getX(), self.circle:getY(), 
                  self.circle:getX(), self.circle:getY() + self.circle:getRadius() + 3, 
                  self.groundCallback)
    self.world:rayCast(self.circle:getX(), self.circle:getY(), 
                  self.circle:getX() + self.circle:getRadius(), self.circle:getY(), 
                  self.leftRightCallback)
    self.world:rayCast(self.circle:getX(), self.circle:getY(), 
                  self.circle:getX() - self.circle:getRadius(), self.circle:getY(), 
                  self.leftRightCallback)
    self.world:rayCast(self.circle:getX(), self.circle:getY(), 
                  self.circle:getX(), self.circle:getY() - (self.circle:getRadius() + 3), 
                  self.topCallback)

    if self.blocked.right and self.blocked.left then
        print("SQUASHED")
        self:dead()
        return
    end

    self.state = self.onGround and "ground" or "air"

    local velX, velY = self.circle.body:getLinearVelocity()
    local moveDir = self.moveVector.x < 0 and -1 or self.moveVector.x > 0 and 1 or 0
    local maxSpeed = self.maxSpeed * math.abs(self.moveVector.x)^2
    maxSpeed = math.max(0, 2*(maxSpeed-0.5))

    -- Apply force if below maxSpeed (or trying to stop)
    if self.onGround and velX * moveDir < maxSpeed then
        self.circle.body:applyForce(self.acceleration[self.state] * self.moveVector.x, 0)
    elseif not self.onGround and velX * moveDir < maxSpeed/2 then
        self.circle.body:applyForce(self.acceleration[self.state] * self.moveVector.x, 0)
    end

    if math.abs(velX) < self.floorSpeed then
        velX = 0
        self.circle.body:setLinearVelocity(velX, velY)
    elseif velX * self.moveVector.x <= 0 then -- Not moving or trying to stop
        self.circle.body:applyForce(-velX*self.friction[self.state], 0)
    end

    if self.jump and self.onGround and self.jumpPool == self.jumpPoolMax then
        -- Stop so we don't get irregular jump heights
        self.circle.body:setLinearVelocity(self.circle.body:getLinearVelocity(),0)
    end
    if self.jump and self.jumpPool > 0 and (self.onGround or self.jumpPool ~= self.jumpPoolMax) then
        self.circle.body:applyForce(0, -1 * jumpForce * self.jumpPool^jumpExp)
        self.jumpPool = self.jumpPool - dt
    end
end

function player:draw()
    self.circle:draw()
end

function player:getX()
    return self.circle:getX()
end

function player:getY()
    return self.circle:getY()
end

return player

