local abs = math.abs

local function sign( value )
  if value == 0 then
    return 0
  else
    return value / abs(value)
  end
end

local function signChanged( absolute, delta )
  local lastAbsolute = absolute - delta
  return sign(lastAbsolute) ~= sign(absolute)
end

return {sign = sign,
        signChanged = signChanged}
