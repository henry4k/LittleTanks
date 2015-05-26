local class = require 'middleclass'
local Vector = require 'Vector'
local Controllable = require 'Controllable'
local MovableEntity = require 'littletanks.MovableEntity'


local Tank = class('littletanks.Tank', MovableEntity)
Tank:include(Controllable)

function Tank:initialize()
  MovableEntity.initialize(self)
  self:initializeControllable()

  self:setSize(Vector(16, 16))

  self.steering = Vector(0, 0)
  self.friction = 0.9

  self.chassis = nil
  self.turret  = nil
end

function Tank:destroy()
  self:destroyControllable()

  MovableEntity.destroy(self)
end

function Tank:setChassis( chassis )
  if self.chassis then
    self.chassis:destroy()
  end
  self.chassis = chassis
end

function Tank:setTurret( turret )
  if self.turret then
      self.turret:destroy()
  end
  self.turret = turret
end

function Tank:update( timeDelta )
  self.force = self.steering * 40

  self.chassis:update(timeDelta)
  self.turret:update(timeDelta)
  MovableEntity.update(self, timeDelta)
end

function Tank:draw()
  love.graphics.push()
    love.graphics.translate(self:getPosition():unpack(2))

    self.chassis:draw()

    love.graphics.push()
      love.graphics.translate(self.chassis.turretAttachmentPoint:unpack(2))
      self.turret:draw()
    love.graphics.pop()
  love.graphics.pop()
end

Tank:mapControl('moveX', function( self, absolute, delta )
  self.steering[1] = absolute
end)

Tank:mapControl('moveY', function( self, absolute, delta )
  self.steering[2] = -absolute
end)

return Tank
