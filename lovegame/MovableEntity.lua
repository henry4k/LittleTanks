local class = require 'middleclass'
local Vector = require 'Vector'
local Entity = require 'lovegame.Entity'


local MovableEntity = class('lovegame.MovableEntity', Entity)

function MovableEntity:initialize()
  Entity.initialize(self)

  self.friction = 0

  self.force = Vector(0, 0)
  self.velocity = Vector(0, 0)
end

function MovableEntity:update( timeDelta )
  Entity.update(self, timeDelta)

  local velocity = self.velocity
  local position = self.position

  velocity = velocity + self.force * timeDelta

  velocity = velocity * (1 - self.friction * timeDelta)

  position = position + velocity * timeDelta

  self.position = position
  self.velocity = velocity
end

return MovableEntity
