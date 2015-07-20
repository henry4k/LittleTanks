local class = require 'middleclass'
local anim8 = require 'anim8'
local resources = require 'littletanks.resources'
local TankTurret = require 'littletanks.TankTurret'


local SimpleTankTurret = class('littletanks.SimpleTankTurret', TankTurret)

function SimpleTankTurret.static:initializeStatic()
  if self.initializedStatic then
    return
  end

  local image = resources['littletanks/tank.png']
  self.image = image

  local grid = anim8.newGrid(14,
                             10,
                             image:getWidth(),
                             image:getHeight(),
                             0,
                             80)
  self.animationPresets = {
    [0]   = { frames = grid:getFrames(1,1, 2,1) },
    [45]  = { frames = grid:getFrames(1,2, 2,2) },
    [90]  = { frames = grid:getFrames(1,3, 2,3) },
    [135] = { frames = grid:getFrames(1,4, 2,4) },
    [180] = { frames = grid:getFrames(1,5, 2,5) }
  }

  self.initializedStatic = true
end

function SimpleTankTurret:initialize()
  TankTurret.initialize(self)
  SimpleTankTurret:initializeStatic()
  self:setAnimation(0)
end

function SimpleTankTurret:update( timeDelta )
  TankTurret.update(self, timeDelta)
  self.animation:update(timeDelta)
end

function SimpleTankTurret:draw()
  self.animation:draw(self.image, -7, -5)
end

function SimpleTankTurret:setAnimation( name )
  local preset = self.animationPresets[name]
  self.animation = anim8.newAnimation(preset.frames, 0.3)
end

return SimpleTankTurret
