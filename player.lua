
player = {}

local playerStart = { x = 600, y = 300 }
local radius = 20
local mass = 25
local imgPath = "gfx/characters/circle-ph.png"

player.label = "player"

player.acceleration = { air = 20000, ground = 50000 }
player.maxSpeed = 10000
player.jumpForce = 100000
player.jumpPoolMax = 1
player.friction = { air = 0.1, ground = 500 }
player.floorSpeed = 0.005

player.state = "ground"
player.onGround = false
player.moveVector = { x = 0, y = 0 }
player.jumpPool = jumpPoolMax

player.circle = nil
player.world = nil

function player:getGroundCallback()
    local self = self
    local function groundHitCallback(fixture, x, y, xn, yn, fraction)
        self.onGround = true
        other = fixture:getUserData()
        if other and other.wasHitCallback then
            other.wasHitCallback(other, fixture, x, y, xn, yn, fraction, self)
        end
        return 0
    end
    return groundHitCallback
end

function player:print()
    print("--- Player info: ---")
    print("state:\t", self.state)
    print("position: ", self.circle:getX(), self.circle:getY())
    print("moveVector: ", self.moveVector.x, self.moveVector.y)
    print()
end

function player:load(world)
    self.world = world

    self.circle = love.filesystem.load("circle.lua")()
    self.circle:load(world, playerStart.x, playerStart.y, radius, imgPath)

    self.circle.fixture:setRestitution(0.1) -- bounce
    self.circle.body:setSleepingAllowed(false)
    self.circle.body:setMass(mass)
    self.circle.fixture:setUserData(self)
end

function player:update(dt)
    self.state = self.onGround and "ground" or "air"

    self.circle.body:applyForce(self.acceleration[self.state] * self.moveVector.x, 0)

    velX, velY = self.circle.body:getLinearVelocity()
    if false and velX > self.maxSpeed then
        self.circle.body:setLinearVelocity(self.maxSpeed, velY)
    elseif math.abs(velX) < self.floorSpeed then
        velX = 0
        self.circle.body:setLinearVelocity(velX, velY)
    elseif velX * self.moveVector.x <= 0 then -- Not moving or trying to stop
        self.circle.body:applyForce(-velX*self.friction[self.state], 0)
    end

    if self.jump and self.jumpPool > 0 and (self.onGround or self.jumpPool ~= self.jumpPoolMax) then
        self.circle.body:applyForce(0, -1 * self.jumpForce * self.jumpPool^10)
        self.jumpPool = self.jumpPool - dt
    end

    self.onGround = false
    self.world:rayCast(self.circle:getX(), self.circle:getY(), 
                  self.circle:getX(), self.circle:getY() + self.circle:getRadius() + 5, 
                  player:getGroundCallback())
end

function player:draw()
    self.circle:draw()
end

function player:keyreleased(key)
    if key == 'w' then
        self.moveVector.y = self.moveVector.y + 1.0;
    end
    if key == 'a' then
        self.moveVector.x = self.moveVector.x + 1.0;
    end
    if key == 's' then
        self.moveVector.y = self.moveVector.y - 1.0;
    end
    if key == 'd' then
        self.moveVector.x = self.moveVector.x - 1.0;
    end

    if key == ' ' then
        self.jump = false
    end
end

function player:keypressed(key) 
    if key == 'w' then
        self.moveVector.y = self.moveVector.y - 1.0;
    end
    if key == 'a' then
        self.moveVector.x = self.moveVector.x - 1.0;
    end
    if key == 's' then
        self.moveVector.y = self.moveVector.y + 1.0;
    end
    if key == 'd' then
        self.moveVector.x = self.moveVector.x + 1.0;
    end

    if key == ' ' then
        self.jumpPool = self.jumpPoolMax
        self.jump = true
    end
end

function player:getX()
    return self.circle:getX()
end

function player:getY()
    return self.circle:getY()
end

return player

