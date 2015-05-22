local class = require 'middleclass'
local anim8 = require 'anim8'
local Vector = require 'Vector'
local Aabb = require 'Aabb'


local TileMapView = class('lovegame.TileMapView')

function TileMapView:initialize( atlasImage, tileWidth, tileHeight, maxSprites )
  tileHeight = tileHeight or tileWidth

  self.tileWidth  = tileWidth
  self.tileHeight = tileHeight

  self.atlasGrid = anim8.newGrid(tileWidth, tileHeight,
                                 atlasImage:getDimensions())
  self.spriteBatch = love.graphics.newSpriteBatch(atlasImage, maxSprites, 'dynamic')
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

function TileMapView:set( tileMap, aabb )
  local tileWidth   = self.tileWidth
  local tileHeight  = self.tileHeight
  local atlasGrid   = self.atlasGrid
  local spriteBatch = self.spriteBatch
  spriteBatch:clear()

  local xStart, yStart = aabb.min:unpack(2)
  local width, height = aabb:size():unpack(2)

  for yOffset = 0, height-1 do
  for xOffset = 0,  width-1 do
    local tile = tileMap:at(xStart+xOffset,
                            yStart+yOffset)
    local atlasX, atlasY = tile:getAtlasCoords()
    local quad = atlasGrid:getFrames(atlasX, atlasY)[1]
    spriteBatch:add(quad, tileWidth*xOffset, tileHeight*yOffset)
  end
  end

  spriteBatch:flush()
end

function TileMapView:draw( ... )
  love.graphics.draw(self.spriteBatch, ...)
end

return TileMapView
