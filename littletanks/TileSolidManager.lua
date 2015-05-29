local class = require 'middleclass'
local TileSolid = require 'littletanks.TileSolid'


local TileSolidManager = class('littletanks.TileSolidManager')

function TileSolidManager:initialize( options )
  assert(options.tileMap and
         options.tileMapView and
         options.physicsWorld)

  self.tileMap = options.tileMap
  self.tileMapView = options.tileMapView
  self.physicsWorld = options.physicsWorld

  self.tileSolids = {} -- sparse array
  self.tileMap:addEventTarget('tileChanged', self, self.onTileChange)
end

function TileSolidManager:destroy()
  self.tileMap:removeEventTarget('tileChanged', self)
end

function TileSolidManager:onTileChange( tilePosition, oldTile, newTile )
  local tileSize = self.tileMapView:getTileSize()

  local pixelPosition = self.tileMapView:tileToPixelCoords(tilePosition)
  pixelPosition = pixelPosition + tileSize*0.5 -- move to tile center

  local tileSolid = TileSolid(newTile, pixelPosition, tileSize)
  self:_setTileSolidAt(tilePosition, tileSolid)
end

function TileSolidManager:_getTileSolidAt( position )
  local positionKey = tostring(position)
  return self.tileSolids[positionKey]
end

function TileSolidManager:_setTileSolidAt( position, tileSolid )
  local positionKey = tostring(position)
  local oldTileSolid = self.tileSolids[positionKey]
  if oldTileSolid then
    self.physicsWorld:removeSolid(oldTileSolid)
  end
  self.tileSolids[positionKey] = tileSolid
  if tileSolid then
    self.physicsWorld:addSolid(tileSolid)
  end
end

return TileSolidManager
