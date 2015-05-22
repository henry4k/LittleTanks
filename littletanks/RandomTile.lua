local class = require 'middleclass'
local Tile = require 'littletanks.Tile'


local RandomTile = class('littletanks.RandomTile', Tile)

function RandomTile:initialize( maxX, maxY )
  Tile.initialize(self)
  self.maxX = maxX
  self.maxY = maxY
end

function RandomTile:getAtlasCoords()
  return math.random(1, self.maxX),
         math.random(1, self.maxY)
end

return RandomTile
