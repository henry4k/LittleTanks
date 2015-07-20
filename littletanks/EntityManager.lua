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
  self.physicsWorld:addSolid(entity)
  self.entities[entity] = true
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

function EntityManager:update( timeDelta )
  for entity, _ in pairs(self.entities) do
    entity:update(timeDelta)
  end
end

function EntityManager:draw()
  -- TODO: Sort entities by y position
  for entity, _ in pairs(self.entities) do
    entity:draw()
  end
end

return EntityManager
