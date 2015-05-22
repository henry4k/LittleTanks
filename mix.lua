local cos = math.cos
local pi = math.pi

local function mixLinear( a, b, t )
  return a + (b - a) * t
end

local function mixCosine( a, b, t )
  return mixLinear(a, b, -cos(pi * t) / 2 + 0.5)
end

local function mixSmoothStep( a, b, t )
  return mixLinear(a, b, t * t * (3 - 2 * t))
end

local function mixAcceleration( a, b, t )
  return mixLinear(a, b, t*t)
end

local function mixDeceleration( a, b, t )
  return mixLinear(a, b, 1 - (1-t) * (1-t))
end

return { linear = mixLinear,
         cosine = mixCosine,
         smoothStep = mixSmoothStep,
         acceleration = mixAcceleration,
         deceleration = mixDeceleration }
