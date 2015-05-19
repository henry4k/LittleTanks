local class = require 'middleclass'
local Vector = require 'Vector'


local Entity = class('lovegame.Entity')

function Entity:initialize()
  self.position = Vector(0, 0)
end

function Entity:destroy()
  -- Nothing to do here (yet)
end

function Entity:update( timeDelta )
  -- Nothing to do here (yet)
end

function Entity:draw()
  error('Implementation missing.')
end

return Entity
