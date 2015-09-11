love.filesystem.load("external/LoveTiledMap/tiledmap.lua")()

love.filesystem.load("tiledobjects.lua")()

gCamX,gCamY = 800,1200

playerStart = { x = 200, y = 100 }

player = { img = nil, body = nil, shape = nil, rad = 30 }
moveVector = { x = 0.0, y = 0.0 }

function love.load()
    -- Load environment graphics
    TiledMap_Load("map/map01.tmx")

    -- Load physics world
    love.physics.setMeter(64) --the height of a meter our worlds will be 64px
    world = love.physics.newWorld(0, 9.81*64, true)
    objects = parseObjects("map/map01.tmx")

    for k, obj in ipairs(objects) do
        shape = love.physics.newRectangleShape(obj.width, obj.height);
        body = love.physics.newBody(world, obj.x, obj.y, "static")
        fixture = love.physics.newFixture(body, shape, 5)
    end

    -- Player
    player.img = love.graphics.newImage("gfx/characters/circle-ph.png");
    player.shape = love.physics.newCircleShape(player.rad);
    player.body = love.physics.newBody(world, playerStart.x, playerStart.y, "dynamic")
    fixture = love.physics.newFixture(player.body, player.shape, 1)
    fixture:setRestitution(0.9) --let the ball bounce
end

function love.keyreleased(key)
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

function love.keypressed(key) 
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

function love.update(dt)
    world:update(dt)

    --player.x = player.x + moveVector.x;
    --player.y = player.y + moveVector.y;
end

function love.draw(dt)
    love.graphics.setBackgroundColor(0x80,0x80,0x80)

    -- Draw environment
    TiledMap_DrawNearCam(gCamX, gCamY)

    -- Draw player 
    local x, y = player.shape:getPoint();
    love.graphics.setColor(193, 47, 14) --set the drawing color to red for the ball
    love.graphics.circle("fill", player.body:getX(), player.body:getY(), player.shape:getRadius())
    --love.graphics.draw(player.img, x, y, 0, player.rad / player.img:getWidth());
end
