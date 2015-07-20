local class = require 'middleclass'
local anim8 = require 'anim8'
local Vector = require 'Vector'
local Aabb = require 'Aabb'


local TileMapView = class('littletanks.TileMapView')

function TileMapView:initialize( options )
  assert(options.tileMap and
         options.image and
         options.tileWidth)

  local tileMap = options.tileMap
  local image = options.image
  local tileWidth = options.tileWidth
  local tileHeight = options.tileHeight or tileWidth
  local maxSprites = options.maxSprites

  self.tileMap = tileMap

  self.tileWidth  = tileWidth
  self.tileHeight = tileHeight

  self.imageGrid = anim8.newGrid(tileWidth, tileHeight,
                                 image:getDimensions())
  self.spriteBatch = love.graphics.newSpriteBatch(image, maxSprites, 'dynamic')
end

function TileMapView:destroy()
  -- Nothing to do here (yet)
end

function TileMapView:getTileSize()
  return Vector(self.tileWidth,
                self.tileHeight)
end

function TileMapView:tileToPixelCoords( coords )
  return (coords-1) * self:getTileSize()
end

function TileMapView:pixelToTileCoords( coords )
  return (coords / self:getTileSize()) + 1
end

function TileMapView:tileToPixelAabb( aabb )
  return Aabb(self:tileToPixelCoords(aabb.min),
              self:tileToPixelCoords(aabb.max))
end

function TileMapView:pixelToTileAabb( aabb, snapMethod )
  local exact = Aabb(self:pixelToTileCoords(aabb.min),
                     self:pixelToTileCoords(aabb.max))
  if not snapMethod then
    return exact
  elseif snapMethod == 'inner' then
    return Aabb(exact.min:ceil(),
                exact.max:floor())
  elseif snapMethod == 'outer' then
    return Aabb(exact.min:floor(),
                exact.max:ceil())
  else
    error('Unknown snap method.')
  end
end

function TileMapView:set( aabb )
  local tileMap     = self.tileMap
  local tileWidth   = self.tileWidth
  local tileHeight  = self.tileHeight
  local imageGrid   = self.imageGrid
  local spriteBatch = self.spriteBatch

  assert(tileMap:getBoundaries():contains(aabb),
         'Requested area exceeds tile map.')

  spriteBatch:clear()

  local xStart, yStart = aabb.min:unpack(2)
  local width, height = aabb:size():unpack(2)

  for yOffset = 0, height-1 do
  for xOffset = 0,  width-1 do
    local tilePosition = Vector(xStart+xOffset,
                                yStart+yOffset)
    local tile = tileMap:at(tilePosition)
    local atlasX, atlasY = tile:getAtlasCoords()
    local quad = imageGrid:getFrames(atlasX, atlasY)[1]
    spriteBatch:add(quad, tileWidth*xOffset, tileHeight*yOffset)
  end
  end

  spriteBatch:flush()
end

function TileMapView:draw( ... )
  love.graphics.draw(self.spriteBatch, ...)
end

return TileMapView
