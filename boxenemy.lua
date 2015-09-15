
boxEnemy = {}

boxEnemy.density = 1
boxEnemy.label = "boxEnemy"

boxEnemy.world = nil
boxEnemy.shape = nil
boxEnemy.body = nil
boxEnemy.fixture = nil
boxEnemy.img = nil
boxEnemy.state = "idle"

function boxEnemy:print()
    print(string.format("--- %s ---", self.label))
    print("state:\t", state)
    print("position:", self.body:getX(), self.body:getY())
    print()
end

function boxEnemy:load(world, x, y, width, height, imgPath)
    if imgPath then
        self.img = love.graphics.newImage(imgPath)
    end

    self.shape = love.physics.newRectangleShape(width, height)
    self.body = love.physics.newBody(world, x, y)
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)

    self.fixture:setRestitution(0) -- no bounce
    self.body:setMass(width*height*self.density)
    self.body:setUserData(self.label)
end

function boxEnemy:update()
end

function boxEnemy:draw()
    if imgPath then
        love.graphics.draw(img, self.body:getX(), self.body:getY(), 0, 
                           self.shape:getWidth() / img:getWidth())
    else
        love.graphics.rectangle("fill", self.body:getX(), self.body:getY(), 
                                self.shape:getWidth, self.shape:getHeight)
    end
end

return boxEnemy
