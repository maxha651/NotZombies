sti = require "Simple-Tiled-Implementation"
love.filesystem.load("player.lua")()
love.filesystem.load("evilbox.lua")()

prePath = love.filesystem.getWorkingDirectory

gCamX,gCamY = 0, 0

debug_timer = 0

npcList = nil

physicsDebug = true

function love.load()

    -- Load Tiled map
    map = sti.new("map/map02.lua", { "box2d" })

    -- Load physics
    love.physics.setMeter(70)
    world = love.physics.newWorld(0, 9.81*70, true)

    collision = map:box2d_init(world)

    --npcList = npcInit.addInstances(world)

    -- Create a Custom Layer
    map:addCustomLayer("Player Layer", 3)

    -- Add data to Custom Layer
    player:load(world)
    evilbox:load(world)

    local playerLayer = map.layers["Player Layer"]
    playerLayer.sprites = {
        player = {
            image = love.graphics.newImage("gfx/characters/circle-ph.png"),
            x = 800,
            y = 800,
            r = 0,
        }
    }

    function playerLayer:update(dt)
    end

    function playerLayer:draw()
        for _, sprite in pairs(self.sprites) do
            local x = math.floor(sprite.x)
            local y = math.floor(sprite.y)
            local r = sprite.r
            --love.graphics.draw(sprite.image, x, y, r)
        end
    end
end

function love.quit()
end

function love.focus(inFocus)
end

function love.keyreleased(key)
    player:keyreleased(key)
end

function love.keypressed(key) 
    player:keypressed(key)
end

function love.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
end

function love.update(dt)
    map:update(dt)
    world:update(dt)
    player:update(dt)
    evilbox:update(dt)

    printDebug()
end

function love.draw()
    local translateX = player:getX() - love.graphics:getWidth()/2
    local translateY = player:getY() - love.graphics:getHeight()/2

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

    player:draw()
    evilbox:draw()

    love.graphics.print(love.timer.getFPS(), love.graphics:getWidth()+translateX-50, translateY+10)
end

function printDebug()
    time = love.timer.getTime()

    if (time - debug_timer > 1) then
        player:print()
        evilbox:print()
        debug_timer = time
    end
end

