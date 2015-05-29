local class = require 'middleclass'
local Vector = require 'Vector'
local Aabb = require 'Aabb'


local Solid = class('littletanks.Solid')

function Solid:initialize()
  self:updatePosition(Vector(0, 0))
  self:setSize(Vector(1, 1))
end

function Solid:destroy()
  -- Nothing to do here (yet)
end

function Solid:getPosition()
  return self._position
end

function Solid:teleportTo( newPosition )
  assert(not self.positionModification)
  self._position = newPosition
  self.positionModification = 'teleported'
end

function Solid:moveTo( newPosition )
  assert(not self.positionModification)
  self._position = newPosition
  self.positionModification = 'moved'
end

function Solid:updatePosition( newPosition )
  self._position = newPosition
  self.positionModification = false
end

function Solid:getTopLeft()
  return self._position - self._halfSize
end

function Solid:setSize( size )
  self._halfSize = size / 2
end

function Solid:getSize()
  return self._halfSize * 2
end

function Solid:getBoundaries()
  local position = self._position
  local halfSize = self._halfSize
  return Aabb(position - halfSize,
              position + halfSize)
end

local defaultCollisionCategories = {}

function Solid:getCollisionCategories()
  return defaultCollisionCategories
end

function Solid:onCollision( collision )
  -- Nothing to do here (yet)
end

return Solid
