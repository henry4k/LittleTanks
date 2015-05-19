local class = require 'middleclass'
local floor = math.floor


local function coordToIndex( x, y, width )
  return y*width + x
end

local function indexToCoords( index, width )
  index = index - 1 -- turn into zero based index
  local x = index % width
  local y = floor(index / width)
  return x+1, y+1 -- use one based indices again
end


local TileMap = class('lovegame.TileMap')

function TileMap:initialize( options )
  local width    = options.width
  local height   = options.height

  assert(width and height)

  self.width    = width
  self.height   = height
  self.idToTileMap = {}
  self.tileToIdMap = {}

  self:_initializeMap()
end

function TileMap:_initializeMap()
  local width  = self.width
  local height = self.height
  local map = {}

  for y = 1, height do
  for x = 1, width do
    local index = coordToIndex(x, y, width)
    map[index] = 1
  end
  end

  self.map = map
end

function TileMap:registerTile( tile )
  assert(not self.tileToIdMap[tile], 'Tile has already been registered.')
  table.insert(self.idToTileMap, tile)
  self.tileToIdMap[tile] = #self.idToTileMap
end

function TileMap:isInBounds( x, y )
  return x >= 1 and x <= self.width and
         y >= 1 and y <= self.height
end

function TileMap:at( x, y )
  if self:isInBounds(x,y) then
    local index = coordToIndex(x, y, self.width)
    local tileId = self.map[index]
    return self.idToTileMap[tileId]
  end
end

function TileMap:setAt( x, y, tile )
  assert(self:isInBounds(x, y, 'Out of bounds!'))
  local index = coordToIndex(x, y, self.width)
  local tileId = self.tileToIdMap[tile]
  self.map[index] = id
end

return TileMap
