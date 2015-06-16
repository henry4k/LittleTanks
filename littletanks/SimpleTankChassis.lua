local class = require 'middleclass'
local anim8 = require 'anim8'
local Vector = require 'Vector'
local resources = require 'littletanks.resources'
local TankChassis = require 'littletanks.TankChassis'


local SimpleTankChassis = class('littletanks.SimpleTankChassis', TankChassis)

function SimpleTankChassis.static:initializeStatic()
  if self.initializedStatic then
    return
  end

  local image = resources['littletanks/tank.png']
  self.image = image

  local grid = anim8.newGrid(16, 16, image:getDimensions())
  self.animationPresets = {
    [0]   = { frames = grid:getFrames(1,1, 2,1), turretAttachmentPoint = Vector(0, 0) },
    [45]  = { frames = grid:getFrames(1,2, 2,2), turretAttachmentPoint = Vector(0, 0) },
    [90]  = { frames = grid:getFrames(1,3, 2,3), turretAttachmentPoint = Vector(0, 0) },
    [135] = { frames = grid:getFrames(1,4, 2,4), turretAttachmentPoint = Vector(0, 0) },
    [180] = { frames = grid:getFrames(1,5, 2,5), turretAttachmentPoint = Vector(0, 0) }
  }

  self.initializedStatic = true
end

function SimpleTankChassis:initialize()
  TankChassis.initialize(self)
  SimpleTankChassis:initializeStatic()
  self:setAnimation(0)
end

function SimpleTankChassis:update( timeDelta, tank )
  TankChassis.update(self, timeDelta)
  --self.animation:setDurations()
  self.animation:update(timeDelta * tank.velocity:length())
end

function SimpleTankChassis:draw()
  local xScale = 1
  if self.flipImage then
    xScale = -1
  end
  self.animation:draw(self.image, -8*xScale, -8, 0, xScale, 1)
end

function TankChassis:onTankRotation( angle )
  local angleInDegree = math.deg(angle)
  local animationName = math.abs(angleInDegree)
  local flipImage = angle < 0

  self:setAnimation(animationName)
  self.flipImage = flipImage
end

function SimpleTankChassis:setAnimation( name )
  local preset = self.animationPresets[name]
  self.animation = anim8.newAnimation(preset.frames, 0.1)
  self.turretAttachmentPoint = preset.turretAttachmentPoint
end

return SimpleTankChassis
