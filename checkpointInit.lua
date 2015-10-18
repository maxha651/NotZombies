-- Some glue to make STI and checkpoint.lua stick together
-- Overall not very nice code

checkpointInit = {}

-- Create checkpoint objects from Tiled stuff
function checkpointInit.initLayer(map, layer, _, player)
    local objects = map.layers[layer].objects
    
    local checkpointList = {}

    for _, object in pairs(objects) do
        local checkpoint = love.filesystem.load("checkpoint.lua")()

        checkpoint:load(player, object.x + map.tilewidth/2,
                        object.y - map.tileheight/2, object.width, object.height)

        checkpointList[#checkpointList +1] = checkpoint
        if object.name then
            checkpointList[object.name] = checkpoint
        end
    end

    -- Tell STI that we're handling stuff
    map:convertToCustomLayer(layer)

    return checkpointList
end

return checkpointInit
