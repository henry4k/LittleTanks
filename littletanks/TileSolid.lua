local class = require 'middleclass'
local Solid = require 'littletanks.Solid'


local TileSolid = class('littletanks.TileSolid', Solid)

function TileSolid:initialize( tile, position, tileSize )
  Solid.initialize(self)
  self:setSize(tileSize)
  self:teleportTo(position)
  self.tile = tile
end

function Solid:getCollisionCategories()
  return self.tile.getCollisionCategories()
end
