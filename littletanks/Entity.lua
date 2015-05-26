local class = require 'middleclass'
local Vector = require 'Vector'
local Aabb = require 'Aabb'


local Entity = class('littletanks.Entity')

Entity.static.id = 1

function Entity:initialize()
  self.name = 'Entity '..Entity.static.id
  Entity.static.id = Entity.static.id + 1

  self:updatePosition(Vector(0, 0))
  self:setSize(Vector(1, 1))
end

function Entity:destroy()
  -- Nothing to do here (yet)
end

function Entity:getPosition()
  return self._position
end

function Entity:teleportTo( newPosition )
  assert(not self.positionModification)
  self._position = newPosition
  self.positionModification = 'teleported'
end

function Entity:moveTo( newPosition )
  assert(not self.positionModification)
  self._position = newPosition
  self.positionModification = 'moved'
end

function Entity:updatePosition( newPosition )
  self._position = newPosition
  self.positionModification = false
end

function Entity:getTopLeft()
  return self._position - self._halfSize
end

function Entity:setSize( size )
  self._halfSize = size / 2
end

function Entity:getSize()
  return self._halfSize * 2
end

function Entity:getBoundaries()
  local position = self._position
  local halfSize = self._halfSize
  return Aabb(position - halfSize,
              position + halfSize)
end

function Entity:update( timeDelta )
  -- Nothing to do here (yet)
end

function Entity:onCollision( other )
  -- Nothing to do here (yet)
end

function Entity:draw()
  error('Implementation missing.')
end

function Entity:__tostring()
  return self.name
end

return Entity
