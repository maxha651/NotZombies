
boxEnemy = {}

boxEnemy.density = 0.01
boxEnemy.label = "boxEnemy"

boxEnemy.world = nil
boxEnemy.shape = nil
boxEnemy.body = nil
boxEnemy.fixture = nil
boxEnemy.img = nil
boxEnemy.state = "idle"

boxEnemy.width = 0
boxEnemy.height = 0

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
    self.body = love.physics.newBody(world, x, y, "dynamic")
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)

    self.fixture:setRestitution(0) -- no bounce
    self.body:setMass(width*height*self.density)
    self.body:setUserData(self.label)

    self.width = width
    self.height = height
end

function boxEnemy:update()
end

function boxEnemy:draw()
    if imgPath then
        love.graphics.draw(img, self.body:getX(), self.body:getY(), 0, 
                           self.width / img:getWidth())
    else
        love.graphics.rectangle("fill", self.body:getX()-self.width/2, self.body:getY()-self.height/2, 
                                self.width, self.height)
    end
end

return boxEnemy
