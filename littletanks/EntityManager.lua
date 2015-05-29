local class = require 'middleclass'
local Vector = require 'Vector'


local EntityManager = class('littletanks.EntityManager')

function EntityManager:initialize( options )
  assert(options.physicsWorld)

  self.physicsWorld = options.physicsWorld
  self.entities = {}
end

function EntityManager:destroy()
  for entity, _ in pairs(self.entities) do
    self:destroyEntity(entity)
  end
end

function EntityManager:addEntity( entity )
  self.physicsWorld:addSolid(entity, entity:getBoundaries())
  self.entities[entity] = true
  entity:updatePosition(entity:getPosition())
end

function EntityManager:destroyEntity( entity )
  self.physicsWorld:destroySolid(entity)
  self.entities[entity] = nil
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
  local bumpWorld = self.physicsWorld.bumpWorld -- TODO

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

  for _, collision in ipairs(collisions) do
    assert(entity ~= collision.other)
    collision = self:_refineCollisionInfo(collision)
    entity:onCollision(collision)
  end
end

function EntityManager:update( timeDelta )
  for entity, _ in pairs(self.entities) do
    self:_updateEntity(entity, timeDelta)
  end
end

function EntityManager:draw()
  -- TODO: Sort entities by y position
  for entity, _ in pairs(self.entities) do
    entity:draw()
  end
end

return EntityManager
