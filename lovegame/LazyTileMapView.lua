local class = require 'middleclass'
local Aabb = require 'Aabb'
local TileMapView = require 'lovegame.TileMapView'
local debug2d = require 'debug2d'


local LazyTileMapView = class('lovegame.LazyTileMapView', TileMapView)

function LazyTileMapView:initialize( ... )
  TileMapView.initialize(self, ...)
  self.outerAabb = Aabb()
end

function LazyTileMapView:setMargin( margin )
  self.margin = margin
end

function LazyTileMapView:setOuter( tileMap, aabb )
  TileMapView.set(self, tileMap, aabb)
  self.tileMap = tileMap
  self.outerAabb = aabb
end

function LazyTileMapView:set( tileMap, aabb )
  self.innerAabb = aabb
  local outerAabb = self.outerAabb
  if tileMap ~= self.tileMap or not outerAabb:contains(aabb) then
    local margin = self.margin
    local newOuterAabb = Aabb(aabb.min - margin,
                              aabb.max + margin)
    newOuterAabb = tileMap:getBoundaries():intersection(newOuterAabb)
    if not outerAabb:contains(newOuterAabb) then
      debug2d.setAabb('outerAabb', 0, 255, 0, self:tileToPixelAabb(newOuterAabb))
      self:setOuter(tileMap, newOuterAabb)
    end
  end
end

function LazyTileMapView:draw( ... )
  love.graphics.push()
    local offset = self:tileToPixelCoords(self.outerAabb.min)
    love.graphics.translate(offset:unpack(2))
    TileMapView.draw(self, ...)
  love.graphics.pop()
end

return LazyTileMapView
