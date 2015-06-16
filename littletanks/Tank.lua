local class = require 'middleclass'
local Vector = require 'Vector'
local Controllable = require 'Controllable'
local MovableEntity = require 'littletanks.MovableEntity'


local Tank = class('littletanks.Tank', MovableEntity)
Tank:include(Controllable)

function Tank:initialize()
  MovableEntity.initialize(self)
  self:initializeControllable()

  self:setSize(Vector(14, 8))

  self:setSteering(Vector(0, 0))
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
  if chassis then
    self:setSteering(self._steering)
  end
end

function Tank:setTurret( turret )
  if self.turret then
      self.turret:destroy()
  end
  self.turret = turret
end

function Tank:update( timeDelta )
  self.force = self._direction * (self._throttle * 40)

  self.chassis:update(timeDelta, self)
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

local up = Vector(0, 1)
local upAtan2 = math.atan2(up[2], up[1])
local function NormalToAngle( normal )
  local angle = upAtan2 - math.atan2(normal[2], normal[1])
  if angle <= math.pi then
    return angle
  else
    return angle - math.pi*2
  end
end

local function round( value )
  local fraction = value % 1
  if fraction < 0.5 then
    return math.floor(value)
  else
    return math.ceil(value)
  end
end

function Tank:setSteering( steering )
  self._steering = steering

  if steering[1] ~= 0 or
     steering[2] ~= 0 then
    self._throttle = steering:length()

    local direction = steering:normalize()

    local angle = NormalToAngle(direction)
    local stepSize = math.pi / 4
    local snappedAngle = round(angle / stepSize) * stepSize
    local snappedDirection = Vector(math.sin(snappedAngle),
                                    math.cos(snappedAngle))

    self._direction = snappedDirection

    if self.chassis then
      self.chassis:onTankRotation(snappedAngle)
    end
  else
    self._throttle = 0
    self._direction = self._direction or Vector(0, 1)
  end
end

Tank:mapControl('moveX', function( self, absolute, delta )
  local steering = self._steering
  steering[1] = absolute
  self:setSteering(steering)
end)

Tank:mapControl('moveY', function( self, absolute, delta )
  local steering = self._steering
  steering[2] = -absolute
  self:setSteering(steering)
end)

return Tank
