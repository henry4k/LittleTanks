local class = require 'middleclass'
local Vector = require 'Vector'


local Aabb = class('Aabb')

function Aabb:initialize( ... )
  local args = {...}
  if #args == 0 then
    self.min = Vector(0, 0)
    self.max = Vector(0, 0)
  elseif #args == 4 then
    self.min = Vector(args[1], args[2])
    self.max = Vector(args[3], args[4])
  elseif #args == 2 then
    self.min = args[1]
    self.max = args[2]
  else
    error('Wrong parameters')
  end

  assert(#self.min == 2 and #self.max == 2, 'Invalid values')
  assert(self.max:componentsGreaterOrEqualTo(self.min), 'Max smaller than min')
end

function Aabb:unpack()
  local min = self.min
  local max = self.max
  return min[1],
         min[2],
         max[1],
         max[2]
end

function Aabb:size()
  return self.max - self.min
end

function Aabb:contains( value )
  if Vector:isInstance(value) then
    local point = value
    return point:componentsGreaterOrEqualTo(self.min) and
           point:componentsLesserOrEqualTo(self.max)
  else
    local other = value
    return other.min:componentsGreaterOrEqualTo(self.min) and
           other.max:componentsLesserOrEqualTo(self.max)
  end
end

function Aabb:intersects( other )
  return other.min:componentsLesserThan(self.max) and
         other.max:componentsGreaterThan(self.min)
end

function Aabb:intersection( other )
  return Aabb(math.max(self.min[1], other.min[1]),
              math.max(self.min[2], other.min[2]),
              math.min(self.max[1], other.max[1]),
              math.min(self.max[2], other.max[2]))
end

function Aabb:__mul( value )
  return Aabb(self.min * value,
              self.max * value)
end

function Aabb:__div( value )
  return Aabb(self.min / value,
              self.max / value)
end

function Aabb:__tostring()
  return ('min(%s), max(%s)'):format(self.min, self.max)
end


return Aabb
