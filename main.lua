love.filesystem.load("external/LoveTiledMap/tiledmap.lua")()
love.filesystem.load("player.lua")()
love.filesystem.load("tiledobjects.lua")()
love.filesystem.load("npcinit.lua")()

local gCamX,gCamY = 0, 0

local debug_timer = 0

local npcList = nil

function love.load()
    -- Load modules

    -- Load environment graphics
    TiledMap_Load("map/map01.tmx")

    -- Load physics world
    love.physics.setMeter(64) --the height of a meter our worlds will be 64px
    world = love.physics.newWorld(0, 9.81*64, true)
    objects = parseObjects("map/map01.tmx")

    for k, obj in ipairs(objects) do
        shape = love.physics.newRectangleShape(obj.width, obj.height);
        body = love.physics.newBody(world, obj.x+obj.width/2, obj.y+obj.height/2, "static")
        fixture = love.physics.newFixture(body, shape, 5)
    end

    npcList = npcInit.addInstances(world)
    print("number: ", #npcList)

    player.load(world)
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
    world:update(dt)

    for k, npc in ipairs(npcList) do
        npc:update()
    end

    player.update(dt, world)

    gCamX = player.getX() - love.graphics:getWidth()/2
    gCamY = player.getY() - love.graphics:getHeight()/2

    debug()
end

function love.draw()
    -- minimal camera
    love.graphics.translate(-gCamX, -gCamY)

    love.graphics.setBackgroundColor(0x80,0x80,0x80)

    -- Draw environment
    TiledMap_DrawNearCam(gCamX + love.graphics:getWidth()/2, 
                         gCamY + love.graphics:getHeight()/2)

    for k, npc in ipairs(npcList) do
        npc:draw()
    end

    -- Draw player 
    player.draw()
    -- Draw physics shapes
    --love.graphics.rectangle("fill", objects[1].x, objects[1].y, objects[1].width, objects[1].height)

end

function debug()
    time = love.timer.getTime()

    if (time - debug_timer > 1) then
        for k, npc in ipairs(npcList) do
            npc:print()
        end
        player.print()
        debug_timer = time
    end
end

