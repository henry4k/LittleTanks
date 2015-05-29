local config = require 'config'
local Vector = require 'Vector'


local debugtools = {}

function debugtools.drawText()
  local yOffset = 0
  for key, value in pairs(debugtools.values) do
    local text = ('%s: %s'):format(key, value)
    love.graphics.print(text, 10, 10+yOffset)
    yOffset = yOffset + 30
  end
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

return debugtools
