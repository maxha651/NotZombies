anim8 = require "anim8/anim8"

-- A checkpoint in the world
-- Will help player respawn

checkpoint = {}

local imgPath = "gfx/environment/checkpoint-ani.png"
local playerImgPath = "gfx/characters/player.png"
local animDuration = 0.18
local tileWidth, tileHeight = 70, 70
local stateSwitchTime = 1

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
    if state == "active" and self.state == "inactive" or
        state == "dead" and self.state == "active" then

        self.lastStateSwitch = love.timer.getTime()
        self.state = state
    else
        --print(string.format("Couldn't do state switch %s -> %s", self.state, state))
    end
end

function checkpoint:getLeftRightCallback()
    local self = self
    local function callback(fixture, x, y, xn, yn, fraction)
        other = fixture:getUserData()
        if other.label == "player" and self.state == "inactive" then
            self.activator = other
            other.checkpoint = self
            self:switchState("active")
        end
        return 0
    end
    return callback
end

function checkpoint:load(world, x, y, width, height)
    self.world = world
    self.x, self.y = x, y

    self.rect = love.filesystem.load("rect.lua")()
    self.rect:load(world, x, y, width, height, nil)

    self.rect.body:setType("static")
    self.rect.fixture:setSensor(true)
    self.rect.fixture:setMask(evilboxCollisionMask)
    self.rect.fixture:setUserData(self)

    self.anim.img = love.graphics.newImage(imgPath);
    self.anim.grid = anim8.newGrid(tileWidth, tileHeight, self.anim.img:getWidth(),
                                   self.anim.img:getHeight(), 10, 10); -- margins
    self.anim.anim = anim8.newAnimation(self.anim.grid("1-4",1, 2,1, 4,1, 1,1, 3,1), animDuration)

    self.playerImg = love.graphics.newImage(playerImgPath)

    self.leftRightCallback = self:getLeftRightCallback()
end

function checkpoint:reload()
end

function checkpoint:update(dt)
    self.world:rayCast(self.rect:getX(), self.rect:getY(), 
                       self.rect:getX() + self.rect:getWidth()/2, self.rect:getY(), 
                       self.leftRightCallback)
    self.world:rayCast(self.rect:getX(), self.rect:getY(), 
                       self.rect:getX() - self.rect:getWidth()/2, self.rect:getY(), 
                       self.leftRightCallback)

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
    if physicsDebug then
        self.rect:draw()
    end
    local scale = self.currentScale
    if scale > 0 then
        self.anim.anim:draw(self.anim.img, self.x - scale * tileWidth/2, 
                            self.y - scale * tileHeight/2, 0, scale)
        if self.activator then
            love.graphics.push()
            love.graphics.translate(self.x, self.y)
            love.graphics.rotate(self.activator.circle.body:getAngle())
            love.graphics.translate(-self.x, -self.y)
            love.graphics.setColor(255,255,255,100)
            love.graphics.draw(self.playerImg, self.x - scale * tileWidth/4,
                               self.y - scale * tileHeight/4, 0, 
                               tileWidth/self.playerImg:getWidth()*scale/2)
            love.graphics.setColor(255,255,255,255)
            love.graphics.pop()
        end
    end
end

function checkpoint:print()
end

return checkpoint
