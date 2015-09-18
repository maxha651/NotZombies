
player = {}

local acceleration = { air = 20000, ground = 50000 }
local maxSpeed = 10000
local jumpForce = 100000
local jumpPoolMax = 1
local friction = { air = 0.1, ground = 500 }
local floorSpeed = 0.005

local state = "ground"
local onGround = false
local moveVector = { x = 0, y = 0 }
local jumpPool = jumpPoolMax

local playerStart = { x = 600, y = 300 }
local radius = 20
local mass = 25
local imgPath = "gfx/characters/circle-ph.png"

local circle = nil
local world = nil

function player.print()
    print("--- Player info: ---")
    print("state:\t", state)
    print("position: ", circle:getX(), circle:getY())
    print("moveVector: ", moveVector.x, moveVector.y)
    print()
end

function player.load(world_p)
    world = world_p

    circle = love.filesystem.load("circle.lua")()
    circle:load(world, playerStart.x, playerStart.y, radius, mass, imgPath)

    circle.fixture:setRestitution(0.1) -- bounce
    circle.body:setSleepingAllowed(false)
    circle.body:setMass(mass)
    circle.body:setUserData("player")
end

function groundHitCallback(fixture, x, y, xn, yn, fraction)
    onGround = true
    return 0
end

function player.update(dt)
    state = onGround and "ground" or "air"

    circle.body:applyForce(acceleration[state] * moveVector.x, 0)

    velX, velY = circle.body:getLinearVelocity()
    if false and velX > maxSpeed then
        circle.body:setLinearVelocity(maxSpeed, velY)
    elseif math.abs(velX) < floorSpeed then
        velX = 0
        circle.body:setLinearVelocity(velX, velY)
    elseif velX * moveVector.x <= 0 then -- Not moving or trying to stop
        circle.body:applyForce(-velX*friction[state], 0)
    end

    if jump and jumpPool > 0 and (onGround or jumpPool ~= jumpPoolMax) then
        circle.body:applyForce(0, -1 * jumpForce * jumpPool^10)
        jumpPool = jumpPool - dt
    end

    onGround = false
    world:rayCast(circle:getX(), circle:getY(), 
                  circle:getX(), circle:getY() + circle:getRadius() + 1, 
                  groundHitCallback)
end

function player.draw()
    circle:draw()
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

    if key == ' ' then
        jump = false
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

    if key == ' ' then
        jumpPool = jumpPoolMax
        jump = true
    end
end

function player.getX()
    return circle:getX()
end

function player.getY()
    return circle:getY()
end

return player

