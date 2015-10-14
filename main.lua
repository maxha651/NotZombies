sti = require "Simple-Tiled-Implementation"

love.filesystem.load("player.lua")()
love.filesystem.load("input.lua")()
love.filesystem.load("evilbox.lua")()

-- Collision masks used by Box2d (1 is default ?)
playerCollisionMask = 2
evilboxCollisionMask = 3
oneMeter = 70

debugInfo = false 
physicsDebug = false 

-- Loaded from Tiled map
tileWidth = 0
tileHeight = 0

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

    spawningPlayer = true
    spawnRotation = 0
    spawnScale = 0
end

function love.load()
    love.handlers.reload = reload

    input.load()

    -- Load Tiled map
    map = sti.new("map/map05.lua", { "box2d" })
    tileWidth = map.tileWidth
    tileHeight = map.tileHeight

    -- Load physics
    love.physics.setMeter(oneMeter)
    world = love.physics.newWorld(0, 9.81*oneMeter, true)

    collision = map:box2d_init(world)
    loadCustomLayers(map, world)
    player:load(world)

    if npcs.checkpoint and npcs.checkpoint.start then
        npcs.checkpoint.start.currentScale = 1
        npcs.checkpoint.start.state = "active"
        npcs.checkpoint.start.activator = player
        player.checkpoint = npcs.checkpoint.start
        reload()
    end
end

function love.quit()
end

function love.focus(inFocus)
end

function love.update(dt)
    require("lurker/lurker").update()

    if spawningPlayer then
        spawnScale = spawnScale + dt
        if spawnScale >= 1 then
            spawnScale = 1
            spawningPlayer = false
        end
        player.circle.body:setAngle(player.circle.body:getAngle() + 10 * dt)
        player.circle.radius = spawnScale * 20
        return
    end
    
    if love.keyboard.isDown('r') then
        reload()
    end


    for npcType, _ in pairs(npcs) do
        for _, npc in ipairs(npcs[npcType]) do
            npc:update(dt)
        end
        --map:setObjectCoordinates(map.layers[customLayers[npcType]])
    end

    player:update(dt)

    map:update(dt)
    world:update(dt)

    if debugInfo then
        printDebug()
    end
end

function love.draw()
    local translateX = player:getX() - love.graphics:getWidth()/2
    local translateY = player:getY() - love.graphics:getHeight()/2

    love.graphics.translate(-translateX, -translateY)

    love.graphics.setBackgroundColor(0x80,0x80,0x80)

    -- Draw Range culls unnecessary tiles
    map:setDrawRange(translateX, translateY, love.graphics:getWidth(), 
                     love.graphics:getHeight())

    -- Draw the map and all objects within
    map:draw()

    if physicsDebug then
        love.graphics.setColor(255, 0, 0, 255)
        map:box2d_draw(collision)
        love.graphics.setColor(255, 255, 255, 255)
    end
 
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

