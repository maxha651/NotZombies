
player = {}

local state = "ground"

local acceleration = 10000
local moveVector = { x = 0, y = 0 }

local mass = 100
local maxSpeed = 1000
local jumpForce = 100
local radius = 20
local friction = { air = 0, ground = 0.1 }

local shape = nil
local body = nil
local img = nil

local playerStart = { x = 200, y = 100 }

function player.print()
    print("--- Player info: ---")
    print("state:\t", state)
    print("position: ", player.getX(), player.getY())
    print("moveVector: ", moveVector.x, moveVector.y)
    print()
end

function player.load()
    img = love.graphics.newImage("gfx/characters/circle-ph.png");

    shape = love.physics.newCircleShape(radius);
    body = love.physics.newBody(world, playerStart.x, playerStart.y, "dynamic")
    fixture = love.physics.newFixture(body, shape, 1)

    fixture:setRestitution(0.1) -- bounce
    body:setSleepingAllowed(false)
    body:setMass(mass)
end

function player.update(dt)
    body:applyForce(acceleration * moveVector.x, acceleration * moveVector.y)

    velX, velY = body:getLinearVelocity()
    if false and velX > maxSpeed then
        body:setLinearVelocity(maxSpeed, velY)
    end
end

function player.draw()
    love.graphics.draw(img, player.getX(), player.getY(), 0, radius / img:getWidth());
    --love.graphics.circle("fill", player.getX(), player.getY(), radius)
end

function player.keyreleased(key)
    if key == 'w' then
        moveVector.y = moveVector.y + 1.0;
    end
    if key == 'a' then
        moveVector.x = moveVector.x + 1.0;
    end
    if key == 's' then
        moveVector.y = moveVector.y - 1.0;
    end
    if key == 'd' then
        moveVector.x = moveVector.x - 1.0;
    end
end

function player.keypressed(key) 
    if key == 'w' then
        moveVector.y = moveVector.y - 1.0;
    end
    if key == 'a' then
        moveVector.x = moveVector.x - 1.0;
    end
    if key == 's' then
        moveVector.y = moveVector.y + 1.0;
    end
    if key == 'd' then
        moveVector.x = moveVector.x + 1.0;
    end
end

function player.getX()
    return body:getX()
end

function player.getY()
    return body:getY()
end

return player

