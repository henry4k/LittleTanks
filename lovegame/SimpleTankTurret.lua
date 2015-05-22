local class = require 'middleclass'
local anim8 = require 'anim8'
local resources = require 'lovegame.resources'
local TankTurret = require 'lovegame.TankTurret'


local SimpleTankTurret = class('lovegame.SimpleTankTurret', TankTurret)

function SimpleTankTurret:initialize()
  TankTurret.initialize(self)

  local image = resources['tank.png']
  self.image = image

  local grid = anim8.newGrid(11,
                             8,
                             image:getWidth(),
                             image:getHeight(),
                             0,
                             11)

  local frames = grid:getFrames('1-2', 1)
  local animation = anim8.newAnimation(frames, 0.3)

  self.animation = animation
end

function SimpleTankTurret:update( timeDelta )
  TankTurret.update(self, timeDelta)

  self.animation:update(timeDelta)
end

function SimpleTankTurret:draw()
  self.animation:draw(self.image, -4, -6)
end

return SimpleTankTurret
