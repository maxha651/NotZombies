sti = require "Simple-Tiled-Implementation"
shine = require "shine"

love.filesystem.load("player.lua")()
love.filesystem.load("input.lua")()
love.filesystem.load("evilbox.lua")()

-- Collision masks used by Box2d (1 is default ?)
playerCollisionMask = 2
evilboxCollisionMask = 3
oneMeter = 70

debugInfo = false 
physicsDebug = false 
fpsCounter = false

start = true

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
            npcs[custom] = layerHandlers[custom].initLayer(map, k, world, player)
        end
    end
end

local function reload(arg)
    if arg == "hard" then
        print("Thanks for playing!")
        player.checkpoint = npcs.checkpoint.start
    end
    density = 0
    destroyingPlayer = true
    spawningPlayer = true
    spawnScale = 1
end

function love.load()
    love.handlers.reload = reload

    input.load()

    -- Load Tiled map
    map = sti.new("map/map01.lua", { "box2d" })
    tileWidth = map.tileWidth
    tileHeight = map.tileHeight

    -- Load Tiled maps for menus
    pause_map = sti.new("map/pause_menu.lua")
    start_map = sti.new("map/start_menu.lua")

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
        player:reload()
        spawningPlayer = true
        spawnScale = 0
        density = 1
    end

    love.graphics.setBackgroundColor(0x80,0x80,0x80)
    
    local gaussianblur = shine.gaussianblur{ sigma = 0.6 }
    local godsray = shine.godsray{ exposure = 0.1, decay = 1, density = 1 }

    post_effect = gaussianblur
    cp_post_effect = godsray:chain(gaussianblur)
    density = 1
end

function love.quit()
end

function love.focus(inFocus)
end

function love.keypressed(key, isrepeat)
    keypressed = true
end

function love.joystickpressed(joystick, button)
    keypressed = true
end

function love.update(dt)
    input.update(dt)

    if input.getStartPressed() then
        paused = not paused
    end

    -- Pause with start until any key is pressed
    if start and keypressed then
        start, paused = false, false
    end

    if paused then
        return
    end

    if start then 
        -- Run one update to init at start, then pause
        paused = true
    end

    if destroyingPlayer then
        cp_post_effect.density = density
        cp_post_effect.exposure = 0.055 + 0.1 * density
        density = density + dt
        spawnScale = spawnScale - dt
        if spawnScale <= 0 then
            spawnScale = 0
            density = 1
            destroyingPlayer = false
            for npcType, _ in pairs(npcs) do
                for _, npc in ipairs(npcs[npcType]) do
                    npc:reload()
                end
                --map:setObjectCoordinates(map.layers[customLayers[npcType]])
            end
            player:reload()
        end
        player.circle.body:setAngle(player.circle.body:getAngle() - 10 * dt)
        player.circle.radius = spawnScale * 20
        return

    elseif spawningPlayer then
        cp_post_effect.density = density
        cp_post_effect.exposure = 0.055 + 0.1 * density
        density = density - dt
        spawnScale = spawnScale + dt
        if spawnScale >= 1 then
            spawnScale = 1
            spawningPlayer = false
        end
        player.circle.body:setAngle(player.circle.body:getAngle() + 10 * dt)
        player.circle.radius = spawnScale * 20

        for _, cp in ipairs(npcs["checkpoint"]) do
            cp:update(dt)
        end
        return
    end
    
    if input.getReset() then
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

function draw()
end

function love.draw()
    local translateX = player:getX() - love.graphics:getWidth()/2
    local translateY = player:getY() - love.graphics:getHeight()/2

    if density > 0 then
        cp_post_effect:draw(function()
            love.graphics.push()

            -- Draw background (for PP)
            love.graphics.setColor(0x80,0x80,0x80,255)
            love.graphics.rectangle('fill', 0,0, love.graphics.getWidth(), love.graphics.getHeight())
            love.graphics.setColor(255,255,255,255)

            love.graphics.translate(-translateX, -translateY)
            -- Draw Range culls unnecessary tiles
            map:setDrawRange(translateX, translateY, love.graphics:getWidth(), 
                             love.graphics:getHeight())

            map:draw()

            for npcType, _ in pairs(npcs) do
                for _, npc in ipairs(npcs[npcType]) do
                    npc:draw()
                end
            end

            player:draw()

            love.graphics.pop()
        end)
    else
        post_effect:draw(function()
            love.graphics.push()

            -- Draw background (for PP)
            love.graphics.setColor(0x80,0x80,0x80,255)
            love.graphics.rectangle('fill', 0,0, love.graphics.getWidth(), love.graphics.getHeight())
            love.graphics.setColor(255,255,255,255)

            love.graphics.translate(-translateX, -translateY)
            -- Draw Range culls unnecessary tiles
            map:setDrawRange(translateX, translateY, love.graphics:getWidth(), 
                             love.graphics:getHeight())

            map:draw()

            for npcType, _ in pairs(npcs) do
                for _, npc in ipairs(npcs[npcType]) do
                    npc:draw()
                end
            end

            player:draw()

            love.graphics.pop()
        end)
    end

    if physicsDebug then
        love.graphics.push()

        love.graphics.translate(-translateX, -translateY)

        -- Draw Range culls unnecessary tiles
        map:setDrawRange(translateX, translateY, love.graphics:getWidth(), 
                         love.graphics:getHeight())

        love.graphics.setColor(255, 0, 0, 255)
        map:box2d_draw(collision)
        love.graphics.setColor(255, 255, 255, 255)

        love.graphics.pop()
    end

    if start then
        drawMenu(start_map)
    elseif paused then
        drawMenu(pause_map)
    end

    if fpsCounter then
        love.graphics.print(love.timer.getFPS(), love.graphics:getWidth()+translateX-50, translateY+10)
    end
end

function drawMenu(map)
    love.graphics.push()

    local scale = love.graphics.getHeight() / (map.height * 
                                               map.tileheight)
    love.graphics.translate((love.graphics.getWidth() - 
                             scale * map.width * map.tilewidth) / 2, 0)
    love.graphics.scale(scale)

    map:draw()

    love.graphics.pop()
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

