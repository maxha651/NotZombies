love.filesystem.load("external/LoveTiledMap/tiledmap.lua")()

gCamX,gCamY = 800,1200

function love.load()
    TiledMap_Load("map/map01.tmx")
end

function love.keyreleased( key )
    gKeyPressed[key] = nil
end

function love.keypressed( key, unicode ) 
    gKeyPressed[key] = true 
end

function love.update( dt )
end

function love.draw()
    love.graphics.setBackgroundColor(0x80,0x80,0x80)
    TiledMap_DrawNearCam(gCamX,gCamY)
end
