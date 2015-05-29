local class = require 'middleclass'
local Solid = require 'littletanks/Solid'


local Entity = class('littletanks.Entity', Solid)

Entity.static.id = 1

function Entity:initialize()
  Solid.initialize(self)
  self.name = 'Entity '..Entity.static.id
  Entity.static.id = Entity.static.id + 1
end

function Entity:destroy()
  -- Nothing to do here (yet)
  Solid.destroy(self)
end

function Entity:update( timeDelta )
  -- Nothing to do here (yet)
end

function Entity:draw()
  error('Implementation missing.')
end

function Entity:__tostring()
  return self.name
end

return Entity
