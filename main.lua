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
    map = sti.new("map/map01.lua", { "box2d" })

    -- Load physics
    love.physics.setMeter(64) --the height of a meter our worlds will be 64px
    world = love.physics.newWorld(0, 9.81*64, true)

    collision = map:box2d_init(world)

    --npcList = npcInit.addInstances(world)

    --player.load(world)
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
    --world:update(dt)

    --for k, npc in ipairs(npcList) do
    --    npc:update()
    --end

    --player.update(dt, world)

    --gCamX = player.getX() - love.graphics:getWidth()/2
    --gCamY = player.getY() - love.graphics:getHeight()/2

    --debug()
end

function love.draw()
    -- Translation would normally be based on a player's x/y
    local translateX = 500
    local translateY = 500

    love.graphics.setBackgroundColor(0x80,0x80,0x80)

    -- Draw Range culls unnecessary tiles
    map:setDrawRange(-translateX, -translateY, love.graphics:getWidth(), 
                     love.graphics:getHeight())

    -- Draw the map and all objects within
    map:draw()

    -- Draw Collision Map (useful for debugging)
    love.graphics.setColor(255, 0, 0, 255)
    map:box2d_draw(collision)

    -- Reset color
    love.graphics.setColor(255, 255, 255, 255)
    ---- minimal camera
    --love.graphics.translate(-gCamX, -gCamY)

    --love.graphics.setBackgroundColor(0x80,0x80,0x80)

    ---- Draw environment
    --map:box2d_draw(collision)

    --for k, npc in pairs(npcList) do
    --    npc:draw()
    --end

    ---- Draw player 
    --player.draw()
    ---- Draw physics shapes
    ----love.graphics.rectangle("fill", objects[1].x, objects[1].y, objects[1].width, objects[1].height)

end

function debug()
    time = love.timer.getTime()

    if (time - debug_timer > 1) then
        for k, npc in pairs(npcList) do
            npc:print()
        end
        player.print()
        debug_timer = time
    end
end

