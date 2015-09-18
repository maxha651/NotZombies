
rect = {}

rect.world = nil
rect.shape = nil
rect.body = nil
rect.fixture = nil
rect.img = nil
rect.state = "idle"

rect.width = 0
rect.height = 0

function rect:print()
    print(string.format("--- %s ---", self.body:getUserData()))
    print("state:\t", state)
    print("position:", self.body:getX(), self.body:getY())
    print()
end

function rect:load(world, x, y, width, height, imgPath)
    if imgPath then
        self.img = love.graphics.newImage(imgPath)
    end

    self.shape = love.physics.newRectangleShape(width, height)
    self.body = love.physics.newBody(world, x, y, "dynamic")
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)

    self.width = width
    self.height = height
end

function rect:update()
end

function rect:draw()
    if img ~= nil then
        love.graphics.draw(img, self.body:getX(), self.body:getY(), 0, 
                           self.width / img:getWidth())
    end
    if physicsDebug then
        love.graphics.setColor(255, 0, 0, 255)
        love.graphics.rectangle("line", self.body:getX()-self.width/2, 
                                self.body:getY() - self.height/2, 
                                self.width, self.height)
        love.graphics.setColor(255, 255, 255, 255)
    end
end

function rect:getX()
    return self.body:getX()
end

function rect:getY()
    return self.body:getY()
end

function rect:getWidth()
    return self.width
end

function rect:getHeight()
    return self.height
end

return rect
