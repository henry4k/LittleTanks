local class = require 'middleclass'
local Vector = require 'Vector'
local Aabb = require 'Aabb'
local EventSource = require 'EventSource'
local floor = math.floor


local function coordsToIndex( x, y, width )
  return y*width + x
end

local function positionToIndex( position, size )
  return coordsToIndex(position[1], position[2], size[1])
end

local function indexToCoords( index, width )
  index = index - 1 -- turn into zero based index
  local x = index % width
  local y = floor(index / width)
  return x+1, y+1 -- use one based indices again
end

local function indexToPosition( index, size )
  return Vector(indexToCoords(index, size[1]))
end


local TileMap = class('littletanks.TileMap')
TileMap:include(EventSource)

function TileMap:initialize( options )
  self:initializeEventSource()

  assert(options.size and
         options.generator)

  self.boundaries = Aabb(1, 1, options.size:unpack(2))
  self.idToTileMap = {}
  self.tileToIdMap = {}

  self:_initializeMap(options.generator)
end

function TileMap:destroy()
  -- Nothing to do here (yet)
  self:destroyEventSource()
end

function TileMap:_initializeMap( generator )
  local map = {}
  local size = self:getSize()
  local tileCount = size[1] * size[2]
  for index = 1, tileCount do
    local position = indexToPosition(index, size)
    map[index] = generator:getTileAt(position)
  end
  self.map = map
end

function TileMap:registerTile( tile )
  assert(not self.tileToIdMap[tile], 'Tile has already been registered.')
  table.insert(self.idToTileMap, tile)
  self.tileToIdMap[tile] = #self.idToTileMap
end

function TileMap:getSize()
  return self.boundaries.max
end

function TileMap:getBoundaries()
  return self.boundaries
end

function TileMap:isInBounds( position )
  return self.boundaries:contains(position)
end

function TileMap:at( position )
  if self:isInBounds(position) then
    local index = positionToIndex(position, self:getSize())
    local tileId = self.map[index]
    assert(tileId)
    return self.idToTileMap[tileId]
  end
end

function TileMap:setAt( position, tile )
  assert(self:isInBounds(position), 'Out of bounds!')
  local index = positionToIndex(position, self:getSize())
  local tileId = self.tileToIdMap[tile]
  local oldTile = self.idToTileMap[self.map[index]]

  self.map[index] = tileId

  self:fireEvent('tileChanged', position, oldTile, tile)
end

return TileMap
