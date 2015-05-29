local class = require 'middleclass'


local TileSolidManager = class('littletanks.TileSolidManager')

function TileSolidManager:initialize( options )
  assert(options.tileMap and
         options.tileMapView and
         options.physicsWorld)

  self.tileMap = options.tileMap
  self.tileMapView = options.tileMapView
  self.physicsWorld = options.physicsWorld

  self.tileSolids = {} -- sparse array
  self.tileMap:addEventTarget('tileChange', self, self.onTileChange)
end

function TileSolidManager:destroy()
  self.tileMap:removeEventTarget('tileChange', self)
end

function TileSolidManager:onTileChange( tilePosition, oldTile, newTile )
  local tileSize = self.tileMapView:getTileSize()

  local pixelPosition = self.tileMapView:tileToPixelCoords(tilePosition)
  pixelPosition = pixelPosition + tileSize*0.5 -- move to tile center

  local tileSolid = TileSolid(tile, pixelPosition, tileSize)
  self:_setTileSolidAt(index, tileSolid)
end

function TileSolidManager:_getTileSolidAt( index )
  return self.tileSolids[index]
end

function TileSolidManager:_setTileSolidAt( index, tileSolid )
  local oldTileSolid = self.tileSolids[index]
  if oldTileSolid then
    self.physicsWorld:remove(oldTileSolid)
  end
  self.tileSolids[index] = tileSolid
  if tileSolid then
    self.physicsWorld:add(tileSolid)
  end
end

return TileSolidManager
