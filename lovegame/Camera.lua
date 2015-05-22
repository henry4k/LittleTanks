local class = require 'middleclass'
local gamera = require 'gamera'
local mix = require 'mix'
local Vector = require 'Vector'
local Aabb = require 'Aabb'
local getTime = love.timer.getTime
local floor = math.floor
local ceil = math.ceil
local debug2d = require 'debug2d'


local Camera = class('lovegame.Camera')

function Camera:initialize( options )
  assert(options.tileMap and
         options.tileMapView)

  self.tileMap     = options.tileMap
  self.tileMapView = options.tileMapView
  self.interpolationDuration = options.interpolationDuration or 1
  self.interpolationFunction = options.interpolationFunction or mix.deceleration

  self.camera = gamera.new(self:_getWorldBoundaries():unpack())
  self._internalDrawFn = function(...)
      self:_internalDraw(...)
    end

  self:setTargetPosition(0, 0, false)
  self:update(0)
end

function Camera:destroy()
  -- Nothing to do here (yet).
end

function Camera:_getWorldBoundaries()
  local tileMapAabb = self.tileMap:getBoundaries()
  local tileMapView = self.tileMapView
  return tileMapView:tileToPixelAabb(tileMapAabb)
end

function Camera:_getInterpolatedPosition()
  local target = self.target
  local targetPosition = target.position
  local startTime = self.interpolationStartTime

  if not startTime then
    return targetPosition
  else
    local currentTime = getTime()
    local duration = self.interpolationDuration
    local interpolationFunction = self.interpolationFunction
    local startPosition = self.interpolationStartPosition

    local timeDifference = currentTime - startTime
    local factor = timeDifference / duration

    if factor < 1 then
      return interpolationFunction(startPosition,
                                   targetPosition,
                                   factor)
    else
      return targetPosition, true -- crude optimization :/
    end
  end
end

function Camera:setTargetEntity( entity, interpolate )
  if interpolate then
    --self.interpolationStartPosition = self:_getInterpolatedPosition()
    self.interpolationStartPosition = Vector(self.camera:getPosition())
    self.interpolationStartTime = getTime()
  end

  self.target = entity
end

function Camera:setTargetPosition( x, y, interpolate )
  local fakeEntity = { position = Vector(x, y) }
  self:setTargetEntity(fakeEntity, interpolate)
end

function Camera:update( timeDelta )
  local position, stopInterpolation = self:_getInterpolatedPosition()
  if stopInterpolation then
    self.interpolationStartTime = nil
  end
  local camera = self.camera
  self.camera:setPosition(position:unpack(2))
end

function Camera:_internalDraw( left, top, width, height )
  local visiblePixels = Aabb(left, top, left+width, top+height)

  local tileMapView = self.tileMapView

  local visibleTiles       = tileMapView:pixelToTileAabb(visiblePixels, 'outer')
  local visibleTilesPixels = tileMapView:tileToPixelAabb(visibleTiles)

  debug2d.setAabb('visiblePixels', 255, 255, 0, visiblePixels)
  debug2d.setAabb('visibleTilesPixels', 255, 0, 0, visibleTilesPixels)

  tileMapView:set(self.tileMap, visibleTiles)

  tileMapView:draw()

  DRAW_DEBUG_STUFF()
end

function Camera:draw()
  self.camera:draw(self._internalDrawFn)
end

return Camera
