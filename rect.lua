
rect = {}

rect.density = 0.01
rect.label = "rect"

rect.world = nil
rect.shape = nil
rect.body = nil
rect.fixture = nil
rect.img = nil
rect.state = "idle"

rect.width = 0
rect.height = 0

function rect:print()
    print(string.format("--- %s ---", self.label))
    print("state:\t", state)
    print("position:", self.body:getX(), self.body:getY())
    print()
end

function rect:load(world, x, y, width, height, imgPath)
    if imgPath then
        self.img = love.graphics.newImage(imgPath)
    end

    self.shape = love.physics.newRectangleShape(width, height)
    self.body = love.physics.newBody(world, x, y, "kinematic")
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)

    self.fixture:setRestitution(0) -- no bounce
    self.body:setMass(width*height*self.density)
    self.body:setUserData(self.label)

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
        love.graphics.rectangle("line", self.body:getX()-self.width/2, self.body:getY()-self.height/2, 
                                self.width, self.height)
        love.graphics.setColor(255, 255, 255, 255)
    end
end

return rect
