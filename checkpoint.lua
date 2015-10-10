-- A checkpoint in the world
-- Will help player respawn

checkpoint = {}

checkpoint.label = "checkpoint"
checkpoint.x = 0
checkpoint.y = 0
checkpoint.width = 0
checkpoint.height = 0

function checkpoint:getLeftRightCallback()
    local self = self
    local function callback(fixture, x, y, xn, yn, fraction)
        other = fixture:getUserData()
        other.checkpoint = self
        return 0
    end
    return callback
end

function checkpoint:load(world, x, y, width, height)
    self.world = world
    self.x, self.y = x, y

    self.rect = love.filesystem.load("rect.lua")()
    self.rect:load(world, x, y, width, height, nil)

    self.rect.body:setType("static")
    self.rect.fixture:setSensor(true)
    self.rect.fixture:setMask(evilboxCollisionMask)
    self.rect.fixture:setUserData(self)

    self.leftRightCallback = self:getLeftRightCallback()
end

function checkpoint:reload()
end

function checkpoint:update()
    self.world:rayCast(self.rect:getX(), self.rect:getY(), 
                       self.rect:getX() + self.rect:getWidth()/2, self.rect:getY(), 
                       self.leftRightCallback)
    self.world:rayCast(self.rect:getX(), self.rect:getY(), 
                       self.rect:getX() - self.rect:getWidth()/2, self.rect:getY(), 
                       self.leftRightCallback)
end

function checkpoint:draw()
    if physicsDebug then
        self.rect:draw()
    end
end

function checkpoint:print()
end

return checkpoint
