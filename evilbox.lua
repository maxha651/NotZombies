
evilbox = {}

local evilboxStart = { x = 800, y = 300 }
local width, height = 70, 70
local density = 0.01
local imgPath = "gfx/characters/evilbox.png"

evilbox.acceleration = { air = 20000, ground = 50000 }
evilbox.maxSpeed = 10000
evilbox.friction = { air = 100, ground = 200 }
evilbox.floorSpeed = 0.005

evilbox.state = "ground"
evilbox.onGround = false
evilbox.moveVector = { x = 0, y = 0 }

evilbox.rect = nil
evilbox.world = nil

-- TODO Probably remove manual friction

function evilbox:wasHitCallback(fixture, x, y, xn, yn, fraction, other)
end

function evilbox:getGroundCallback()
    local self = self
    local function groundHitCallback(fixture, x, y, xn, yn, fraction)
        self.onGround = true
        other = fixture:getUserData()
        if other and other.wasHitCallback then
            other.wasHitCallback(other, fixture, x, y, xn, yn, self)
        end
        return 0
    end
    return groundHitCallback
end

function evilbox:print()
    print("--- evilbox info: ---")
    print("state:\t", self.state)
    print("position: ", self.rect:getX(), self.rect:getY())
    print("moveVector: ", self.moveVector.x, self.moveVector.y)
    print()
end

function evilbox:load(world)
    self.world = world

    self.rect = love.filesystem.load("rect.lua")()
    self.rect:load(world, evilboxStart.x, evilboxStart.y, width, height, imgPath)

    self.rect.fixture:setRestitution(0.0) -- bounce
    self.rect.body:setMass(width*height*density)
    self.rect.fixture:setUserData(self)
end

function evilbox:update(dt)
    self.state = self.onGround and "ground" or "air"

    self.rect.body:applyForce(self.acceleration[self.state] * self.moveVector.x, 0)

    velX, velY = self.rect.body:getLinearVelocity()
    if false and velX > self.maxSpeed then
        self.rect.body:setLinearVelocity(self.maxSpeed, velY)
    elseif math.abs(velX) < self.floorSpeed then
        velX = 0
        self.rect.body:setLinearVelocity(velX, velY)
    elseif velX * self.moveVector.x <= 0 then -- Not moving or trying to stop
        self.rect.body:applyForce(-velX*self.friction[self.state], 0)
    end

    self.onGround = false
    self.world:rayCast(self.rect:getX(), self.rect:getY(), 
                  self.rect:getX(), self.rect:getY() + self.rect:getHeight() + 1, 
                  evilbox:getGroundCallback())
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

