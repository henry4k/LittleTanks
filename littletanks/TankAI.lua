local class = require 'middleclass'
local Vector = require 'Vector'


local TankAI = class('littletanks.TankAI')

function TankAI:initialize( tank )
  self.tank = tank
  self.minTargetDistance = 10
end

function TankAI:setTargetPosition( position )
  self.target = position
end

function TankAI:setTargetEntity( entity )
  self.target = entity
end

function TankAI:unsetTarget()
  self.target = nil
end

function TankAI:getTargetPosition()
  local target = self.target
  if target then
    if Vector:isInstance(target) then
      return target
    else
      return target:getPosition()
    end
  end
end

function TankAI:getTargetOffset()
  local targetPosition = self:getTargetPosition()
  if targetPosition then
    local tankPosition = self.tank:getPosition()
    return targetPosition - tankPosition
  end
end

function TankAI:update( timeDelta )
  local offset = self:getTargetOffset()
  if offset then
    local distance = offset:length()
    if distance > self.minTargetDistance then
      local direction = self:getTargetOffset():normalize()
      self.tank:setSteering(direction)
    --else
    --  self:unsetTarget()
    --  self.tank.steering = Vector(0, 0)
    end
  end
end

return TankAI
