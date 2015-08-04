local class = require 'middleclass'


local Tile = class('littletanks.Tile')

function Tile:initialize( options )
  assert(options.quadName, 'No quad name given.')
  self.quadName = options.quadName
  self.collisionCategories = {}
end

function Tile:getCollisionCategories()
  return self.collisionCategories
end

function Tile:getQuadName()
  return self.quadName
end

return Tile
