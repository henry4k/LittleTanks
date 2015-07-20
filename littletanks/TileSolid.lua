local class = require 'middleclass'
local Solid = require 'littletanks.Solid'


local TileSolid = class('littletanks.TileSolid', Solid)

function TileSolid:initialize( tile, position, tileSize )
  Solid.initialize(self)
  self.tile = tile
  self.tileSize = tileSize
  self.position = position
end

function Solid:onInitializeBody()
  self._body:setType('static')
  local tileSize = self.tileSize
  self:_addShape(love.physics.newRectangleShape(tileSize:unpack(2)))
  local position = self.position
  self._body:setPosition(position:unpack(2))
end

function TileSolid:getCollisionCategories()
  return self.tile.getCollisionCategories()
end

return TileSolid
