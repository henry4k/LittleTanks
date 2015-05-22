local class = require 'middleclass'
local Tile = require 'littletanks.Tile'


local SimpleTile = class('littletanks.SimpleTile', Tile)

function SimpleTile:initialize( atlasPositionX, atlasPositionY )
  Tile.initialize(self)
  self.atlasPositionX = atlasPositionX
  self.atlasPositionY = atlasPositionY
end

function SimpleTile:getAtlasCoords()
  return self.atlasPositionX,
         self.atlasPositionY
end

return SimpleTile
