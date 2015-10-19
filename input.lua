
tactile = require "tactile/tactile"

input = {}

local PLAYER_ONE = 1

local horizontal, vertical
local jump, reset, start

local startWasDown = false
local startPressed = false
local startTimeout = 1
local lastStartPress = -math.huge

function input.load()
  upKey = tactile.key("up")
  downKey = tactile.key("down")
  leftKey = tactile.key("left")
  rightKey = tactile.key("right")
  wKey = tactile.key('w')
  aKey = tactile.key('a')
  sKey = tactile.key('s')
  dKey = tactile.key('d')

  keyboardXAxis = tactile.binaryAxis(leftKey, rightKey)
  keyboardYAxis = tactile.binaryAxis(upKey, downKey)
  wasdXAxis = tactile.binaryAxis(aKey, dKey)
  wasdYAxis = tactile.binaryAxis(wKey, sKey)
  gamepadXAxis  = tactile.analogStick('leftx', PLAYER_ONE)
  gamepadYAxis  = tactile.analogStick('lefty', PLAYER_ONE)

  horizontal = tactile.newAxis(keyboardXAxis, wasdXAxis, gamepadXAxis)
  vertical = tactile.newAxis(keyboardYAxis, wasdYAxis, gamepadYAxis)

  keyboardJump = tactile.key(' ')
  gamepadJump = tactile.gamepadButton('a', PLAYER_ONE)

  jump = tactile.newButton(keyboardJump, gamepadJump)

  keyboardReset = tactile.key('r')
  gamepadReset = tactile.gamepadButton('y', PLAYER_ONE)

  reset = tactile.newButton(keyboardReset, gamepadReset)

  keyboardStart = tactile.key('escape')
  gamepadStart = tactile.gamepadButton('start', PLAYER_ONE)

  start = tactile.newButton(keyboardStart, gamepadStart)
end

function input.update()
    jump:update()
    reset:update()
    start:update()

    -- tactile bug ?
    if start:isDown() and not startWasDown then 
        startPressed = true
    else
        startPressed = false
    end
    startWasDown = start:isDown()
end

function input.getStartPressed()
    return startPressed
end

function input.getReset()
  return reset:isDown()
end

function input.getJump()
  return jump:isDown()
end

function input.getXAxis()
  return horizontal:getValue()
end

function input.getYAxis()
  return vertical:getValue()
end

