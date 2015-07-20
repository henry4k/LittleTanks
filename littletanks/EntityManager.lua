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
