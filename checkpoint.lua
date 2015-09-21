-- A checkpoint in the world
-- Will help player respawn

checkpoint = {}

checkpoint.x = 0
checkpoint.y = 0
checkpoint.width = 0
checkpoint.height = 0

function checkpoint:getLeftRightCallback()
    local self = self
    local function callback(fixture, x, y, xn, yn, fraction)
        return 0
    end
    return callback
end

function checkpoint:load(world, x, y, width, height)
    print(x, y, width, height)
    self.world = world

    self.rect = love.filesystem.load("rect.lua")()
    self.rect:load(world, x, y, width, height, nil)

    self.rect.body:setType("static")
    self.rect.fixture:setSensor(true)
    self.rect.fixture:setUserData(self)

    self.leftRightCallback = self:getLeftRightCallback()
end

function checkpoint:update()
end

function checkpoint:draw()
    self.rect:draw()
end

function checkpoint:print()
end

return checkpoint
