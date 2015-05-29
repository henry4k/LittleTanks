local class = require 'middleclass'


local Tile = class('littletanks.Tile')

local defaultCollisionCategories = {}

function Tile:getCollisionCategories()
  return defaultCollisionCategories
end

function Tile:getAtlasCoords()
  error('Method not implemented.')
end

return Tile
