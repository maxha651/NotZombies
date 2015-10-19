anim8 = require "anim8/anim8"

-- A checkpoint in the world
-- Will help player respawn

checkpoint = {}

local imgPath = "gfx/environment/checkpoint-ani.png"
local playerImgPath = "gfx/characters/player.png"
local animDuration = 0.18
local tileWidth, tileHeight = 70, 70
local stateSwitchTime = 1
local enableRadius = tileWidth/2

checkpoint.label = "checkpoint"
checkpoint.x = 0
checkpoint.y = 0
checkpoint.width = 0
checkpoint.height = 0
checkpoint.anim = {}
checkpoint.scale = { inactive = 0.15, active = 1, dead = 0 }
checkpoint.state = "inactive"
checkpoint.currentScale = checkpoint.scale[checkpoint.state]
checkpoint.lastStateSwitch = 0
checkpoint.activator = nil

function checkpoint:switchState(state)
    self.lastStateSwitch = love.timer.getTime()
    self.state = state
end

function checkpoint:load(player, x, y, width, height)
    self.x, self.y = x, y
    self.activator = player

    self.anim.img = love.graphics.newImage(imgPath);
    self.anim.grid = anim8.newGrid(tileWidth, tileHeight, self.anim.img:getWidth(),
                                   self.anim.img:getHeight(), 10, 10); -- margins
    self.anim.anim = anim8.newAnimation(self.anim.grid("1-4",1, 2,1, 4,1, 1,1, 3,1), animDuration)

    self.playerImg = love.graphics.newImage(playerImgPath)

    if self.name == "end" then 
        self.scale.inactive = 1
    end
end

function checkpoint:reload()
    if self.activator.checkpoint ~= self and self.activator.checkpoint.name == "start" then
        self:switchState("inactive")
        self.currentScale = self.scale.inactive
    elseif self.activator.checkpoint == self then
        self:switchState("active")
        self.currentScale = self.scale.active
    end
end

function checkpoint:update(dt)
    if self.name == "end" and
        math.sqrt((self.activator:getX() - self.x)^2 + (self.activator:getY() - self.y)^2) 
        <= enableRadius/2 then
        self.activator.checkpoint = nil
        self.state = "dead"
        love.event.push("reload", "hard")
        return
    end

    if self.state == "inactive" and self.activator and
        math.sqrt((self.activator:getX() - self.x)^2 + (self.activator:getY() - self.y)^2) 
        <= enableRadius then
        self.activator.checkpoint = self
        self:switchState("active")
    end

    if self.state == "active" and self.activator.checkpoint ~= self then
        self:switchState("dead")
    end

    local scaleDiff = self.scale[self.state] - self.currentScale
    if scaleDiff > 0 then
        self.currentScale = self.currentScale + math.min(math.abs(scaleDiff), dt)
    elseif scaleDiff < 0 then
        self.currentScale = self.currentScale - math.min(math.abs(scaleDiff), dt)
    end

    self.anim.anim:update(dt)
end

function checkpoint:draw()
    local scale = self.currentScale
    if scale > 0 then
        self.anim.anim:draw(self.anim.img, self.x - scale * tileWidth/2, 
                            self.y - scale * tileHeight/2, 0, scale)
    end
end

function checkpoint:print()
end

return checkpoint
