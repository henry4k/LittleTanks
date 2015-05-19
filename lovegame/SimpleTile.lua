local class = require 'middleclass'
local Tile = require 'lovegame.Tile'


local SimpleTile = class('lovegame.SimpleTile', Tile)

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
