local class = require 'middleclass'


local Tile = class('littletanks.Tile')

function Tile:initialize( options )
  assert(options.atlasX and
         options.atlasY)
  self.atlasX = options.atlasX
  self.atlasY = options.atlasY
  self.collisionCategories = {}
end

function Tile:getCollisionCategories()
  return self.collisionCategories
end

function Tile:getAtlasCoords()
  return self.atlasX,
         self.atlasY
end

return Tile
