local class = require 'middleclass'
local Aabb = require 'Aabb'
local Vector = require 'Vector'


local AtlasImage = class('littletanks.AtlasImage')

function AtlasImage:initialize( image )
  self.image = image
  self.quadDictionary = {}
end

function AtlasImage:setQuad( name, aabb )
  if self.quadDictionary[name] then
    error(('Quad %s already exists!'):format(name))
  end
  local size = aabb:size()
  local quad = love.graphics.newQuad(aabb.min[1],
                                     aabb.min[2],
                                     size[1],
                                     size[2],
                                     self.image:getDimensions())
  self.quadDictionary[name] = quad
end

function AtlasImage:setQuadFromGrid( name, firstAabb, gridPosition )
  local size = firstAabb:size()
  local position = Vector(firstAabb.min[1] + size[1]*(gridPosition[1]-1),
                          firstAabb.min[2] + size[2]*(gridPosition[2]-1))
  return self:setQuad(name, Aabb(position, position+size))
end

function AtlasImage:setQuadStrip( prefix, firstAabb, count )
  for i = 1, count do
    local name = prefix..i
    local gridPosition = Vector(i, 1)
    self:setQuadFromGrid(name, firstAabb, gridPosition)
  end
end

function AtlasImage:getQuad( name )
  local quad = self.quadDictionary[name]
  if not quad then
    error(('Quad %s doesn\'t exist.'):format(name))
  end
  return quad
end

return AtlasImage
