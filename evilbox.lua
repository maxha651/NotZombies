
evilbox = {}

local evilboxStart = { x = 800, y = 300 }
local width, height = 70, 70
local density = 0.01
local imgPath = "gfx/characters/evilbox.png"

evilbox.acceleration = { air = 20000, ground = 50000 } -- probably remove
evilbox.maxSpeed = 10000 -- probably remove
evilbox.speed = 100
evilbox.friction = { air = 100, ground = 200 } -- probably remove
evilbox.floorSpeed = 0.005 -- probremovevevv

evilbox.state = "ground"
evilbox.onGround = false
evilbox.moveVector = { x = 0, y = 0 }
evilbox.blocked = { left = 0, right = 0 }

evilbox.rect = nil
evilbox.world = nil
evilbox.chasee = nil

-- TODO Probably remove manual friction

function evilbox:wasHitCallback(fixture, x, y, xn, yn, fraction, other)
    if other.label == "player" then
        self.chasee = other
    end
end

function evilbox:getGroundCallback()
    local self = self
    local function callback(fixture, x, y, xn, yn, fraction)
        self.onGround = true
        other = fixture:getUserData()
        if other and other.wasHitCallback then
            other.wasHitCallback(other, fixture, x, y, xn, yn, self)
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
        if fixture:getUserData().label then
            -- TODO Do this properly. Seriously
            return -1
        end
        -- This should probably be in update instead, but meh
        local oldX, oldY = self.rect.body:getPosition()
        if x < oldX then
            self.blocked.left = self.blocked.left + 1
            self.rect.body:setPosition(x + self.rect.width/2, oldY)
        else
            self.blocked.right = self.blocked.right + 1
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

function evilbox:load(world)
    self.world = world

    self.rect = love.filesystem.load("rect.lua")()
    self.rect:load(world, evilboxStart.x, evilboxStart.y, width, height, imgPath)

    self.rect.fixture:setRestitution(0.0) -- bounce
    self.rect.body:setMass(width*height*density)
    self.rect.body:setFixedRotation(true)
    self.rect.fixture:setUserData(self)
end

function evilbox:update(dt)
    self.state = self.onGround and "ground" or "air"

    if self.state == "ground" and self.rect.body:getType() == "dynamic" then
        self.rect.body:setType("kinematic")
        self.rect.body:setLinearVelocity(0,0)
    elseif self.state ~= "ground" and self.rect.body:getType() == "kinematic" then
        self.rect.body:setType("dynamic")
    end

    if self.rect.body:getType() == "dynamic" then
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
    else
        if self.onGround and self.chasee then
            local othX = self.chasee:getX()
            local myX = self.rect.body:getX()
            if othX < myX then
                if self.blocked.left == 0 then
                    self.rect.body:setLinearVelocity(-self.speed, 0)
                else
                    self.blocked.left = self.blocked.left - 1
                end
            elseif othX > myX then
                if self.blocked.right then
                    self.rect.body:setLinearVelocity(self.speed, 0)
                else
                    self.blocked.right = self.blocked.right - 1
                end
            end
        end
    end

    self.onGround = false
    self.world:rayCast(self.rect:getX(), self.rect:getY(), 
                  self.rect:getX(), self.rect:getY() + self.rect:getHeight()/2 + 1, 
                  evilbox:getGroundCallback())
    self.world:rayCast(self.rect:getX(), self.rect:getY(), 
                  self.rect:getX() + self.rect:getWidth()/2, self.rect:getY(), 
                  evilbox:getLeftRightCallback())
    self.world:rayCast(self.rect:getX(), self.rect:getY(), 
                  self.rect:getX() - self.rect:getWidth()/2, self.rect:getY(), 
                  evilbox:getLeftRightCallback())
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

