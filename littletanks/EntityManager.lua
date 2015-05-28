local class = require 'middleclass'
local bump = require 'bump'
local Vector = require 'Vector'
local Aabb = require 'Aabb'
local debug2d = require 'debug2d'


local EntityManager = class('littletanks.EntityManager')

function EntityManager:initialize( options )
  assert(options.worldBoundaries and
         options.cellSize)

  self.worldBoundaries = options.worldBoundaries
  self.bumpWorld = bump.newWorld(options.cellSize)
  self.entities = {}
end

function EntityManager:destroy()
  for entity, _ in pairs(self.entities) do
    self:destroyEntity(entity)
  end
end

function EntityManager:addEntity( entity )
  local topLeft = entity:getTopLeft()
  local size    = entity:getSize()
  self.bumpWorld:add(entity,
                     topLeft[1],
                     topLeft[2],
                     size[1],
                     size[2])
  self.entities[entity] = true
  entity:updatePosition(entity:getPosition())
end

function EntityManager:destroyEntity( entity )
  self.bumpWorld:remove(entity)
  self.entities[entity] = nil
  entity:destroy()
end

function EntityManager:getEntitiesAt( position, filter )
  return self.bumpWorld:queryPoint(position[1],
                                   position[2],
                                   filter)
end

function EntityManager:getEntitiesIn( aabb, filter )
  local aabbSize = aabb:size()
  return self.bumpWorld:queryRect(aabb.min[1],
                                  aabb.min[2],
                                  aabbSize[1],
                                  aabbSize[2],
                                  filter)
end

function EntityManager:getEntitiesAlong( lineStart, lineEnd, filter )
  return self.bumpWorld:querySegment(lineStart[1],
                                     lineStart[2],
                                     lineEnd[1],
                                     lineEnd[2],
                                     filter)
end

local function FilterColliders( entityA, entityB )
  -- TODO
  return 'slide'
end

function EntityManager:_refineCollisionInfo( collision )
  -- move: The difference between the original coordinates and the actual ones.
  -- normal: The collision normal; usually -1,0 or 1 in `x` and `y`
  -- touch: The coordinates where item started touching other

  local move   = collision.move
  local normal = collision.normal
  local touch  = collision.touch

  collision.move = Vector(move.x, move.y)
  collision.normal = Vector(normal.x, normal.y)
  collision.touch = Vector(touch.x, touch.y)

  return collision
end

function EntityManager:_updateEntity( entity, timeDelta )
  local bumpWorld = self.bumpWorld

  entity:update(timeDelta)

  local topLeft = entity:getTopLeft()
  local topLeftOffset = entity:getPosition() - topLeft

  local actualX, actualY, collisions
  if entity.positionModification == 'moved' then
    actualX, actualY, collisions =
      bumpWorld:move(entity, topLeft[1], topLeft[2], FilterColliders)
  else
    if entity.positionModification == 'teleported' then
      bumpWorld:update(entity, topLeft[1], topLeft[2])
    end
    actualX, actualY, collisions =
      bumpWorld:check(entity, topLeft[1], topLeft[2], FilterColliders)
    -- TODO: ^- Correct?
  end

  entity:updatePosition(Vector(actualX, actualY) + topLeftOffset)
  debug2d.setAabb(entity, 0, 255, 0, entity:getBoundaries())

  for _, collision in ipairs(collisions) do
    assert(entity ~= collision.other)
    collision = self:_refineCollisionInfo(collision)
    entity:onCollision(collision)
  end
end

function EntityManager:update( timeDelta )
  local bumpWorld = self.bumpWorld
  for entity, _ in pairs(self.entities) do
    self:_updateEntity(entity, timeDelta)
  end
end

function EntityManager:draw()
  local bumpWorld = self.bumpWorld
  -- TODO: Sort entities by y position
  for entity, _ in pairs(self.entities) do
    entity:draw()
  end
end

return EntityManager
