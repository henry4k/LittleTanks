local class = require 'middleclass'
local anim8 = require 'anim8'
local TankTurret = require 'lovegame.TankTurret'


local SimpleTankTurret = class('lovegame.SimpleTankTurret', TankTurret)

function SimpleTankTurret:initialize()
  TankTurret.initialize(self)

  local image = love.graphics.newImage('LittleTank.png')
  self.image = image

  local grid = anim8.newGrid(16, 16, image:getDimensions())
  local frames = grid:getFrames('1-4', 1)
  local animation = anim8.newAnimation(frames, 0.3)

  self.animation = animation
end

function SimpleTankTurret:update( timeDelta )
  TankTurret.update(self, timeDelta)

  self.animation:update(timeDelta)
end

function SimpleTankTurret:draw()
  self.animation:draw(self.image, -8, -8)
end

return SimpleTankTurret
