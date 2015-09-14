
boxEnemy = {}

boxEnemy.density = 1
boxEnemy.label = "boxEnemy"

boxEnemy.world = nil
boxEnemy.shape = nil
boxEnemy.body = nil
boxEnemy.fixture = nil
boxEnemy.img = nil
boxEnemy.width = 0
boxEnemy.height = 0
boxEnemy.x = 0
boxEnemy.y = 0

boxEnemy.state = "idle"

function boxEnemy:print()
    print(string.format("--- %s ---", self.label))
    print("state:\t", state)
    print("position:", self.x, self.y)
    print()
end

function boxEnemy:load(world, x, y, width, height, imgPath)
    if imgPath then
        self.img = love.graphics.newImage(imgPath)
    end

    self.shape = love.physics.newRectangleShape(width, height)
    self.body = love.physics.newBody(self.world, x, y)
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)

    self.fixture:setRestitution(0) -- no bounce
    self.body:setMass(width*height*self.density)
    self.body:setUserData(self.label)

    self.x = x
    self.y = y
    self.width = width
    self.height = height
end

function boxEnemy:update()
end

function boxEnemy:draw()
    if imgPath then
        love.graphics.draw(img. self.x, self.y, 0, self.width / img:getWidth())
    else
        love.graphics.polygon("fill", self.shape:getPoints())
    end
end

return boxEnemy
