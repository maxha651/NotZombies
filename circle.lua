
circle = {}

circle.shape = nil
circle.body = nil
circle.img = nil
circle.world = nil

function circle:load(world, x, y, rad, imgPath)
    self.world = world

    if imgPath then
        self.img = love.graphics.newImage(imgPath);
    end

    self.shape = love.physics.newCircleShape(rad);
    self.body = love.physics.newBody(world, x, y, "dynamic")
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)
end

function circle:draw()
    if self.img ~= nil then
        local radius = self.shape:getRadius()
        local scale = 2*radius / self.img:getWidth()
        love.graphics.push()
        love.graphics.translate(self.body:getX(), (self.body:getY()))
        love.graphics.rotate(self.body:getAngle())
        love.graphics.translate(-self.body:getX(), -self.body:getY())
        love.graphics.draw(self.img, self.body:getX() - radius, 
                           self.body:getY() - radius, 0, scale)
        love.graphics.pop()
    end
    if physicsDebug and self.body:isActive() then
        love.graphics.setColor(0, 0, 255, 255)
        love.graphics.circle("line", self.body:getX(), self.body:getY(), 
                             self.shape:getRadius())
        love.graphics.setColor(255, 255, 255, 255)
    end
end

function circle:setEnabled(enabled)
    self.body:setActive(enabled)
end

function circle:getEnabled()
    return self.body:isActive()
end

function circle:getX()
    return self.body:getX()
end

function circle:getY()
    return self.body:getY()
end

function circle:getRadius()
    return self.shape:getRadius()
end

return circle

