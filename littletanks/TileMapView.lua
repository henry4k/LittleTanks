local class = require 'middleclass'
local Vector = require 'Vector'
local Aabb = require 'Aabb'


local TileMapView = class('littletanks.TileMapView')

function TileMapView:initialize( options )
  assert(options.tileMap and
         options.atlasImage and
         options.tileWidth)

  local tileMap = options.tileMap
  local atlasImage = options.atlasImage
  local tileWidth = options.tileWidth
  local tileHeight = options.tileHeight or tileWidth
  local maxSprites = options.maxSprites

  self.tileMap = tileMap

  self.tileWidth  = tileWidth
  self.tileHeight = tileHeight
  self.atlasImage = atlasImage

  self.spriteBatch = love.graphics.newSpriteBatch(atlasImage.image, maxSprites, 'dynamic')
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
  local atlasImage  = self.atlasImage
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
    local quadName = tile:getQuadName()
    local quad = atlasImage:getQuad(quadName)
    spriteBatch:add(quad, tileWidth*xOffset, tileHeight*yOffset)
  end
  end

  spriteBatch:flush()
end

function TileMapView:draw( renderContext )
  renderContext:draw{texture=self.atlasImage.image,
                     context=self.spriteBatch}
end

return TileMapView
