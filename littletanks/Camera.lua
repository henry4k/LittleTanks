local class = require 'middleclass'
local gamera = require 'gamera'
local mix = require 'mix'
local config = require 'config'
local debugtools = require 'debugtools'
local Vector = require 'Vector'
local Aabb = require 'Aabb'
local getTime = love.timer.getTime


local Camera = class('littletanks.Camera')

function Camera:initialize( options )
  assert(options.drawFn, 'Draw function missing.')
  assert(options.worldBoundaries, 'World boundaries missing.')

  self.drawFn = options.drawFn
  self.interpolationDuration = options.interpolationDuration or 1
  self.interpolationFunction = options.interpolationFunction or mix.deceleration

  self.camera = gamera.new(options.worldBoundaries:unpack())
  self._internalDrawFn = function(...)
      self:_internalDraw(...)
    end

  self:setTargetPosition(Vector(0, 0), false)
  self:update(0)

  config:addEventTarget('variableChanged', self, self._onConfigVariableChanged)
end

function Camera:destroy()
  config:removeEventTarget('variableChanged', self)
end


function Camera:_getInterpolatedPosition()
  local targetPosition = self:getTargetPosition()
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

function Camera:_startInterpolation()
  self.interpolationStartPosition = Vector(self.camera:getPosition())
  self.interpolationStartTime = getTime()
end

function Camera:setTargetPosition( position, interpolate )
  if interpolate then
    self:_startInterpolation()
  end
  self.target = position
end

function Camera:setTargetEntity( entity, interpolate )
  if interpolate then
    self:_startInterpolation()
  end
  self.target = entity
end

function Camera:getTargetPosition()
  local target = self.target
  if Vector:isInstance(target) then
    return target
  else
    return target:getPosition()
  end
end

function Camera:update( timeDelta )
  local position, stopInterpolation = self:_getInterpolatedPosition()
  if stopInterpolation then
    self.interpolationStartTime = nil
  end
  self.camera:setPosition(position:unpack(2))
end

function Camera:_internalDraw( left, top, width, height )
  local visiblePixels = Aabb(left, top, left+width, top+height)

  self.drawFn(visiblePixels)

  if config:get('debug.camera.visiblePixels.show') then
    debugtools.drawAabb(visiblePixels, 'debug.camera.visiblePixels.color')
  end
end

function Camera:draw()
  self.camera:draw(self._internalDrawFn)
end

function Camera:setScale( scale )
  self.scale = scale
  local debugScale = config:get('debug.camera.scale')
  self.camera:setScale(scale*debugScale)
end

function Camera:onWindowResize( aabb )
  self.windowBoundaries = aabb

  local debugScale = config:get('debug.camera.scale')
  local size = aabb:size()
  local scaledSize = size * debugScale
  local offset = (size - scaledSize) / 2
  aabb = Aabb(aabb.min + offset,
              aabb.min + offset + scaledSize)

  self:_setWindow(aabb)
end

function Camera:_setWindow( aabb )
  self.camera:setWindow(aabb.min[1],
                        aabb.min[2],
                        aabb:size():unpack(2))
end

function Camera:_onConfigVariableChanged( variableName, value )
  if variableName == 'debug.camera.scale' then
    self:onWindowResize(self.windowBoundaries)
    self:setScale(self.scale)
  end
end

return Camera
