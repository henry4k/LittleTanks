local class = require 'middleclass'
local anim8 = require 'anim8'


local LittleTank = class('lovegame.LittleTank')

function LittleTank:initialize()
  local image = love.graphics.newImage('LittleTank.png')
  self.image = image

  local grid = anim8.newGrid(16, 16, image:getDimensions())
  local frames = grid:getFrames('1-4', 1)
  local animation = anim8.newAnimation(frames, 0.3)

  self.animation = animation
end

function LittleTank:update( timeDelta )
  self.animation:update(timeDelta)
end

function LittleTank:draw( ... )
  self.animation:draw(self.image, ...)
end

return LittleTank
