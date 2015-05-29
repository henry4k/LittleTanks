local class = require 'middleclass'
local Vector = require 'Vector'
local Entity = require 'littletanks.Entity'


local MovableEntity = class('littletanks.MovableEntity', Entity)

MovableEntity.static.minAxisVelocity = 0.001

function MovableEntity:initialize()
  Entity.initialize(self)

  self.friction = 0

  self.force = Vector(0, 0)
  self.velocity = Vector(0, 0)
end

function MovableEntity:update( timeDelta )
  Entity.update(self, timeDelta)

  local velocity = self.velocity
  velocity = velocity + self.force * timeDelta

  local minAxisVelocity = self.class.minAxisVelocity
  if velocity[1] >= minAxisVelocity or
     velocity[2] >= minAxisVelocity then

    velocity = velocity * (1 - self.friction * timeDelta)

    local position = self:getPosition()
    position = position + velocity * timeDelta

    self.velocity = velocity
    self:moveTo(position)
  end
end

return MovableEntity
