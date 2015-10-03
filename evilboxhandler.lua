
evilboxhandler = {}

-- Left to right, invert x otherwise
local stackOffset = {
        { x = 70, y = 0 },
        { x = 70, y = 0 },
        { x = 0, y = -70 }, 
}
local stackTime = 1

evilboxhandler.label = "evilboxhandler"

evilboxhandler.updateHandler = nil

function evilboxhandler:print()
end

function evilboxhandler:startCollision(objects, direction)
    if #objects >= 3 then
        self:startStackCollision(objects[1], objects[2], objects[3], direction)
        for _, box in pairs(objects) do
            box.updateHandler = nullHandler
        end
        box[1] = stackCollisionHandler
    end
end

local function stackCollisionHandler(self, dt)
    self.time = self.time + dt
    local time = self.time
    if (time >= self.endTime) then
        for k, box in ipairs(self.boxes) do
            box.rect.body:setPosition(self.endpos[k].x, self.endpos[k].y)
            box.updateHandler = nil
            self.updateHandler = nil
        end
    else
        for k, box in ipairs(self.boxes) do
            local lerp = (time - self.startTime) / (self.endTime - self.startTime)
            print("lerp: ", lerp)
            box.rect.body:setPosition(self.startpos[k].x * (1 - lerp) + self.endpos[k].x * lerp,
                                      self.startpos[k].y * (1 - lerp) + self.endpos[k].y * lerp);
        end
    end
end

local function nullHandler()
end

-- TODO Not really left, middle right (inner, middle, outer ?)
function evilboxhandler:startStackCollision(left, middle, right, direction)
    self.boxes = { left, middle, right }

    for _, box in ipairs(self.boxes) do
        box.state = "idle"
        box.rect.body:setType("kinematic")
        box.rect.body:setLinearVelocity(0,0)
    end

    self.startpos = { 
        { x = left:getX(), y = left:getY() },
        { x = middle:getX(), y = middle:getY() },
        { x = right:getX(), y = right:getY() },
    }

    self.endpos = {}
    for k, pos in ipairs(self.startpos) do
        if direction == "right" then
            self.endpos[k] = { 
                x = pos.x + stackOffset[k].x, 
                y = pos.y + stackOffset[k].y 
            }
        else 
            self.endpos[k] = { 
                x = pos.x - stackOffset[k].x, 
                y = pos.y + stackOffset[k].y 
            }
        end
    end

    self.startTime = love.timer.getTime()
    self.endTime = self.startTime + stackTime

    self.time = love.timer.getTime()
    self.tick = 0
    self.updateHandler = stackCollisionHandler
end

function evilboxhandler:update(dt)
    -- Make sure we only handle every tick once
    if self.updateHandler then
        self.updateHandler(self, dt)
    end
end

return evilboxhandler

