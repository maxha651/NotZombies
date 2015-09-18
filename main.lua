sti = require "Simple-Tiled-Implementation"
love.filesystem.load("player.lua")()
love.filesystem.load("tiledobjects.lua")()
love.filesystem.load("npcinit.lua")()

prePath = love.filesystem.getWorkingDirectory

local gCamX,gCamY = 0, 0

local debug_timer = 0

local npcList = nil

function love.load()

    -- Load Tiled map
    map = sti.new("map/map02.lua", { "box2d" })

    -- Load physics
    love.physics.setMeter(70)
    world = love.physics.newWorld(0, 9.81*70, true)

    collision = map:box2d_init(world)

    --npcList = npcInit.addInstances(world)

    -- Create a Custom Layer
    map:addCustomLayer("Sprite Layer", 3)

    -- Add data to Custom Layer
    player.load(world)

    local playerLayer = map.layers["Sprite Layer"]
    playerLayer.sprites = {
        player = {
            image = love.graphics.newImage("gfx/characters/circle-ph.png"),
            x = 70,
            y = 70,
            r = 0,
        }
    }

    function playerLayer:update(dt)
    end

    function playerLayer:draw()
    end
end

function love.quit()
end

function love.focus(inFocus)
end

function love.keyreleased(key)
    player.keyreleased(key)
end

function love.keypressed(key) 
    player.keypressed(key)
end

function love.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
end

function love.update(dt)
    map:update(dt)
    world:update(dt)
    player.update(dt)


    --for k, npc in ipairs(npcList) do
    --    npc:update()
    --end

    --gCamX = player.getX() - love.graphics:getWidth()/2
    --gCamY = player.getY() - love.graphics:getHeight()/2

    debug()
end

function love.draw()
    local translateX = player.getX() - love.graphics:getWidth()/2
    local translateY = player.getY() - love.graphics:getHeight()/2

    love.graphics.translate(-translateX, -translateY);

    love.graphics.setBackgroundColor(0x80,0x80,0x80)

    -- Draw Range culls unnecessary tiles
    map:setDrawRange(translateX, translateY, love.graphics:getWidth(), 
                     love.graphics:getHeight())

    -- Draw the map and all objects within
    map:draw()

    -- Draw Collision Map (useful for debugging)
    love.graphics.setColor(255, 0, 0, 255)
    map:box2d_draw(collision)

    -- Reset color
    love.graphics.setColor(255, 255, 255, 255)

    player.draw()

    ---- minimal camera
    --love.graphics.translate(-gCamX, -gCamY)

    --love.graphics.setBackgroundColor(0x80,0x80,0x80)

    ---- Draw environment
    --map:box2d_draw(collision)

    --for k, npc in pairs(npcList) do
    --    npc:draw()
    --end

    ---- Draw physics shapes
    ----love.graphics.rectangle("fill", objects[1].x, objects[1].y, objects[1].width, objects[1].height)

end

function debug()
    time = love.timer.getTime()

    if (time - debug_timer > 1) then
        --for k, npc in pairs(npcList) do
        --    npc:print()
        --end
        player.print()
        debug_timer = time
    end
end

