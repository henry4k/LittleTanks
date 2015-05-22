local class = require 'middleclass'
local anim8 = require 'anim8'
local Vector = require 'Vector'
local resources = require 'lovegame.resources'
local TankChassis = require 'lovegame.TankChassis'


local SimpleTankChassis = class('lovegame.SimpleTankChassis', TankChassis)

function SimpleTankChassis:initialize()
  TankChassis.initialize(self)

  self.turretAttachmentPoint = Vector(-1, 0)

  local image = resources['tank.png']
  self.image = image

  local grid = anim8.newGrid(16, 11, image:getDimensions())
  local frames = grid:getFrames(1,1, 3,1)
  local animation = anim8.newAnimation(frames, 0.3)

  self.animation = animation
end

function SimpleTankChassis:update( timeDelta )
  TankChassis.update(self, timeDelta)

  self.animation:update(timeDelta)
end

function SimpleTankChassis:draw()
  self.animation:draw(self.image, -8, -4)
end

return SimpleTankChassis
