
player = {}

local mass = 25
local acceleration = { air = 20000, ground = 50000 }
local maxSpeed = 10000
local jumpForce = 100000
local jumpPoolMax = 1
local radius = 20
local friction = { air = 0.1, ground = 500 }
local floorSpeed = 0.005

local state = "ground"
local onGround = false
local moveVector = { x = 0, y = 0 }
local jumpPool = jumpPoolMax

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

function player.load(world)
    img = love.graphics.newImage("gfx/characters/circle-ph.png");

    shape = love.physics.newCircleShape(radius);
    body = love.physics.newBody(world, playerStart.x, playerStart.y, "dynamic")
    fixture = love.physics.newFixture(body, shape, 1)

    fixture:setRestitution(0.1) -- bounce
    body:setSleepingAllowed(false)
    body:setMass(mass)
    body:setUserData("player")
end

function groundHitCallback(fixture, x, y, xn, yn, fraction)
    onGround = true
    return 0
end

function player.update(dt, world)
    state = onGround and "ground" or "air"

    body:applyForce(acceleration[state] * moveVector.x, 0)

    velX, velY = body:getLinearVelocity()
    if false and velX > maxSpeed then
        body:setLinearVelocity(maxSpeed, velY)
    elseif math.abs(velX) < floorSpeed then
        velX = 0
        body:setLinearVelocity(velX, velY)
    elseif velX * moveVector.x <= 0 then -- Not moving or trying to stop
        body:applyForce(-velX*friction[state], 0)
    end

    if jump and jumpPool > 0 and (onGround or jumpPool ~= jumpPoolMax) then
        body:applyForce(0, -1 * jumpForce * jumpPool^10)
        jumpPool = jumpPool - dt
    end

    onGround = false
    world:rayCast(player.getX(), player.getY(), 
                  player.getX(), player.getY() + radius + 1, 
                  groundHitCallback)
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
    return body:getX()
end

function player.getY()
    return body:getY()
end

return player

