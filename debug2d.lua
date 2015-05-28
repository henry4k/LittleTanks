local debug2d =
{
  values = {},
  aabbs = {}
}

function debug2d.setValue( key, value )
  if type(value) == 'number' then
    value = string.format('%.3f', value)
  end
  debug2d.values[key] = value
end

function debug2d.setAabb( key, r, g, b, aabb )
  debug2d.aabbs[key] = { aabb=aabb, color={r,g,b} }
end

function debug2d.drawText()
  local yOffset = 0
  for key, value in pairs(debug2d.values) do
    local text = ('%s: %s'):format(key, value)
    love.graphics.print(text, 10, 10+yOffset)
    yOffset = yOffset + 30
  end
end

function debug2d.drawAabbs()
  for key, value in pairs(debug2d.aabbs) do
    love.graphics.setColor(unpack(value.color))
    local aabb = value.aabb
    love.graphics.rectangle('line', aabb.min[1],
                                    aabb.min[2],
                                    aabb:size():unpack(2))
    love.graphics.setColor(255, 255, 255)
  end
end

return debug2d
