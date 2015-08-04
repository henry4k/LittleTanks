local class = require 'middleclass'
local Object = class.Object
local Vector = require 'Vector'
local Entity = require 'littletanks.Entity'


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

function EntityManager:draw( renderContext )
  for entity, _ in pairs(self.entities) do
    renderContext:pushTransformation(entity:getPosition():unpack(2))
    entity:draw(renderContext)
    renderContext:popTransformation()
  end
end

local function entityFilter( solid )
  return Object.isInstanceOf(solid, Entity)
end

local function wrapEntityFilter( filter )
  if filter then
    return function( solid )
        return entityFilter(solid) and filter(solid)
      end
  else
    return entityFilter
  end
end

function EntityManager:getEntitiesAt( position, filter )
  local wrappedFilter = wrapEntityFilter(filter)
  return self.physicsWorld:getSolidsAt(position, wrappedFilter)
end

function EntityManager:getEntitiesIn( aabb, filter )
  local wrappedFilter = wrapEntityFilter(filter)
  return self.physicsWorld:getSolidsIn(aabb, wrappedFilter)
end

function EntityManager:getEntitiesAlong( lineStart, lineEnd, filter )
  local wrappedFilter = wrapEntityFilter(filter)
  return self.physicsWorld:getSolidsAlong(lineStart, lineEnd, wrappedFilter)
end

return EntityManager
