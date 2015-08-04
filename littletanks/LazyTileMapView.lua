local class = require 'middleclass'
local Aabb = require 'Aabb'
local TileMapView = require 'littletanks.TileMapView'


local LazyTileMapView = class('littletanks.LazyTileMapView', TileMapView)

function LazyTileMapView:initialize( ... )
  TileMapView.initialize(self, ...)
  self.outerAabb = Aabb()
end

function LazyTileMapView:setMargin( margin )
  self.margin = margin
end

function LazyTileMapView:setOuter( aabb )
  TileMapView.set(self, aabb)
  self.outerAabb = aabb
end

function LazyTileMapView:set( aabb )
  self.innerAabb = aabb
  local outerAabb = self.outerAabb
  if not outerAabb:contains(aabb) then
    local margin = self.margin
    local newOuterAabb = Aabb(aabb.min - margin,
                              aabb.max + margin)
    newOuterAabb = self.tileMap:getBoundaries():intersection(newOuterAabb)
    if not outerAabb:contains(newOuterAabb) then
      self:setOuter(newOuterAabb)
    end
  end
end

function LazyTileMapView:draw( renderContext )
  local offset = self:tileToPixelCoords(self.outerAabb.min)
  renderContext:pushTransformation(offset:unpack(2))
    TileMapView.draw(self, renderContext)
  renderContext:popTransformation()
end

return LazyTileMapView
