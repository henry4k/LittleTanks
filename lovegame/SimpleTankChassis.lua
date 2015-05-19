local class = require 'middleclass'
local anim8 = require 'anim8'
local Vector = require 'Vector'
local TankChassis = require 'lovegame.TankChassis'


local SimpleTankChassis = class('lovegame.SimpleTankChassis', TankChassis)

function SimpleTankChassis:initialize()
  TankChassis.initialize(self)

  self.turretAttachmentPoint = Vector(0, -4)

  local image = love.graphics.newImage('LittleTank.png')
  self.image = image

  local grid = anim8.newGrid(16, 16, image:getDimensions())
  local frames = grid:getFrames('1-4', 1)
  local animation = anim8.newAnimation(frames, 0.3)

  self.animation = animation
end

function SimpleTankChassis:update( timeDelta )
  TankChassis.update(self, timeDelta)

  self.animation:update(timeDelta)
end

function SimpleTankChassis:draw()
  self.animation:draw(self.image, -8, -8)
end

return SimpleTankChassis
