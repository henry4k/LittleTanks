local class = require 'middleclass'
local Tile  = require 'lovegame.Tile'
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
  local width            = options.width
  local height           = options.height
  local tileAtlasRows    = options.tileAtlasRows
  local tileAtlasColumns = options.tileAtlasColumns
  local defaultTileClass = options.defaultTileClass or Tile

  assert(width and height and tileAtlasRows and tileAtlasColumns)

  self.width            = width
  self.height           = height
  self.tileAtlasRows    = tileAtlasRows
  self.tileAtlasColumns = tileAtlasColumns
  self.defaultTileClass = defaultTileClass

  self:_createMap()
  self:_createTileAtlasQuads()
end

function TileMap:_createMap()
  local width  = self.width
  local height = self.height
  local tileClass = self.defaultTileClass
  local map = {}

  for y = 1, height do
  for x = 1, width do
    local index = coordToIndex(x, y, width)
    map[index] = tileClass()
  end
  end

  self.map = map
end

function TileMap:_createTileAtlasQuads()
  local width   = self.width
  local rows    = self.tileAtlasRows
  local columns = self.tileAtlasColumns
  local quads   = {}

  for i = 1, rows*columns do
    local x, y = indexToCoords(i, rows)
    local quad = love.graphics.newQuad(x-1, y-1, 1, 1, rows, columns)
    quads[i] = quad
  end

  self.tileAtlasQuads = quads
end

function TileMap:isInBounds( x, y )
  return x >= 1 and x <= self.width and
         y >= 1 and y <= self.height
end

function TileMap:at( x, y )
  if self:isInBounds(x,y) then
    local index = coordToIndex(x, y, self.width)
    return self.map[index]
  end
end

function TileMap:setAt( x, y, tile )
  assert(self:isInBounds(x, y, 'Out of bounds!'))
  local index = coordToIndex(x, y, self.width)
  self.map[index] = tile
end

function TileMap:fillSpriteBatch( spriteBatch, xStart, yStart, width, height )
  local tileAtlasQuads = self.tileAtlasQuads

  for yOffset = 0, height-1 do
  for xOffset = 0,  width-1 do
    local tile = self:at(xStart+xOffset,
                         yStart+yOffset)
    local quad = tileAtlasQuads[tile.id]
    spriteBatch:add(quad, xOffset, yOffset)
  end
  end
end


return TileMap
