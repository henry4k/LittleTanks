local config = require 'config'
local Vector = require 'Vector'


local debugtools = {}

local function setTransformation( transformation )
  love.graphics.translate(transformation.x,
                          transformation.y)
  love.graphics.rotate(transformation.r)
  love.graphics.scale(transformation.sx,
                      transformation.sy)
end

local function ExtractColorComponents( color )
  if type(color) == 'string' then
    local vector = config:get(color)
    vector = vector * 255
    return vector:unpack(3)
  elseif Vector:isInstance(color) then
    local vector = color
    vector = vector * 255
    return vector:unpack(3)
  end
  error('Don\'t know how to handle color.')
end

function debugtools.drawAabb( aabb, color )
  local r, g, b = ExtractColorComponents(color)
  love.graphics.setColor(r, g, b)
  love.graphics.rectangle('line', aabb.min[1],
                                  aabb.min[2],
                                  aabb:size():unpack(2))
  love.graphics.setColor(255, 255, 255)
end

local function drawAabb( context, transformation )
  love.graphics.push()
    setTransformation(transformation)
    debugtools.drawAabb(unpack(context))
  love.graphics.pop()
end

function debugtools.drawAabbRC( renderContext, ... )
  renderContext:draw{drawFn=drawAabb,
                     context={...}}
end

function debugtools.drawPolygon( color, ... )
  local r, g, b = ExtractColorComponents(color)
  love.graphics.setColor(r, g, b)
  love.graphics.polygon('line', ...)
  love.graphics.setColor(255, 255, 255)
end

local function drawPolygon( context, transformation )
  love.graphics.push()
    setTransformation(transformation)
    debugtools.drawPolygon(unpack(context))
  love.graphics.pop()
end

function debugtools.drawPolygonRC( renderContext, ... )
  renderContext:draw{drawFn=drawPolygon,
                     context={...}}
end

return debugtools
