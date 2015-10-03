sti = require "Simple-Tiled-Implementation"

love.filesystem.load("player.lua")()
love.filesystem.load("input.lua")()
love.filesystem.load("evilbox.lua")()

prePath = love.filesystem.getWorkingDirectory

physicsDebug = true
oneMeter = 70

debug_timer = 0

customLayers = {}
layerHandlers = { 
    evilbox = love.filesystem.load("evilboxInit.lua")(),
    checkpoint = love.filesystem.load("checkpointInit.lua")() 
}

-- TODO rename ?
npcs = { evilbox = {}, checkpoint = {}}

local function loadCustomLayers(map, world)
    for k, layer in ipairs(map.layers) do
        local custom = map:getLayerProperties(k).custom
        if custom then
            assert(layerHandlers[custom], "Handler missing for layer: ", custom)
            customLayers[custom] = k
            npcs[custom] = layerHandlers[custom].initLayer(map, k, world)
        end
    end
end

local function reload()
    for npcType, _ in pairs(npcs) do
        for _, npc in ipairs(npcs[npcType]) do
            npc:reload(dt)
        end
        --map:setObjectCoordinates(map.layers[customLayers[npcType]])
    end

    player:reload(dt)
end


function love.load()
    love.handlers.reload = reload

    input.load()

    -- Load Tiled map
    map = sti.new("map/map03.lua", { "box2d" })

    -- Load physics
    love.physics.setMeter(oneMeter)
    world = love.physics.newWorld(0, 9.81*oneMeter, true)

    collision = map:box2d_init(world)
    loadCustomLayers(map, world)
    player:load(world)
end

function love.quit()
end

function love.focus(inFocus)
end

function love.update(dt)
    require("lurker/lurker").update()

    for npcType, _ in pairs(npcs) do
        for _, npc in ipairs(npcs[npcType]) do
            npc:update(dt)
        end
        --map:setObjectCoordinates(map.layers[customLayers[npcType]])
    end

    player:update(dt)

    map:update(dt)
    world:update(dt)

    --printDebug()
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
    love.graphics.setColor(255, 255, 255, 255)

    for npcType, _ in pairs(npcs) do
        for _, npc in ipairs(npcs[npcType]) do
            npc:draw()
        end
    end

    player:draw()

    love.graphics.print(love.timer.getFPS(), love.graphics:getWidth()+translateX-50, translateY+10)
end

function printDebug()
    time = love.timer.getTime()

    if (time - debug_timer > 1) then
        player:print()

        for npcType, _ in pairs(npcs) do
            for _, npc in ipairs(npcs[npcType]) do
                npc:print(dt)
            end
        end

        debug_timer = time
    end
end

