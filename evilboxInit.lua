-- Some glue to make STI and evilbox.lua stick together
-- Overall not very nice code

evilboxInit = {}

-- Create evilbox objects from Tiled stuff
function evilboxInit.initLayer(map, layer, world)
    local objects = map.layers[layer].objects

    -- Do cool initialization
    local coolObject
    local coolObjects = {}
    for _, object in pairs(objects) do
        coolObject = love.filesystem.load("evilbox.lua")()
        
        -- Make sure we always update STI object 
        -- I'm not sure whether this is a good way to do it...
        -- Probably not needed since I don't seem to get STI to do what I want
        -- anyway...
        local oldUpdate = coolObject.update
        local function funkyUpdateFunc(self, dt)
            oldUpdate(self, dt)
            object.x = coolObject:getX()
            object.y = coolObject:getY()
        end

        -- Converting from bottom-left coordinate to center coordinate
        coolObject:load(world, object.x + map.tilewidth/2, 
                        object.y - map.tileheight/2, 
                        object.width, object.height)
        coolObject.update = funkyUpdateFunc

        coolObjects[#coolObjects +1] = coolObject
    end

    -- Tell STI that we're handling stuff
    map:convertToCustomLayer(layer)

    return coolObjects
end

return evilboxInit
