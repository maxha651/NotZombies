
npcInit = {}

local templates = { boxEnemy = {} }
local instances = { boxEnemy = {} }

local function parseBoxEnemy(tile)
    local k, l, sub1, sub2
    local width, height, img
    for k, sub1 in ipairs(tile) do
        if (sub1.label == "objectgroup") then
            for l, sub2 in ipairs(sub1) do
                if (sub2.label == "object") then
                    width = sub2.xarg.width
                    height = sub2.xarg.height
                end
            end
        end
        if sub1.label == "image" then
            img = sub1.xarg.source
        end
    end
    boxEnemy[tile.xarg.id + 1] = 
    { gid = tile.xarg.id + 1, img = img, width = width, height = height }
end

local function instantiateBoxEnemy(gid, x, y)
    instances.boxEnemy[gid] = { x = x, y = y }
end

function npcInit.instantiateSpecialTile(gid, x, y)
    if templates.boxEnemy[gid] ~= nil then
        instantiateBoxEnemy(gid, x, y)
    end
end

function npcInit.parseSpecialTile(tile)
    local k, l, sub1, sub2
    for k, sub1 in ipairs(tile) do
        if (sub1.label == "properties") then
            for l, sub2 in ipairs(sub1) do
                if (sub2.xarg.name == "boxEnemy") then
                    parseBoxEnemy(tile)
                end
            end
        end
    end
end

function npcInit.templateExists(gid)
    for k, template in pairs(templates) do
        if template[gid] ~= nil then return true end
    end
end

function npcInit.addInstances(world)
    for k, instance in ipairs(instances.boxEnemy) do
        local boxEnemy = love.filesystem.load("boxenemy.lua")()

        boxEnemy:load(world, instance.x, instance.y, templates.boxEnemy[k].width, 
                      templates.boxEnemy[k].height, templates.boxEnemy[k].img)
    end
end

return npcInit
