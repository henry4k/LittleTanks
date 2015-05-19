local class = require 'middleclass'
local anim8 = require 'anim8'


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

function TileMapView:set( tileMap, xStart, yStart, width, height )
  local tileWidth   = self.tileWidth
  local tileHeight  = self.tileHeight
  local atlasGrid   = self.atlasGrid
  local spriteBatch = self.spriteBatch
  spriteBatch:clear()

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
