local class = require 'middleclass'
local bump = require 'bump'
local config = require 'config'
local debugtools = require 'debugtools'


local PhysicsWorld = class('littletanks.PhysicsWorld')

function PhysicsWorld:initialize( options )
  assert(options.cellSize and
         options.worldBoundaries)

  self.worldBoundaries = options.worldBoundaries
  self.bumpWorld = bump.newWorld(options.cellSize)
  self.solids = {}
end

function PhysicsWorld:destroy()
  for solid, _ in pairs(self.solids) do
    self:destroySolid(solid)
  end
end

function PhysicsWorld:addSolid( solid )
  assert(not self.solids[solid], 'Solid has already been added.')
  local aabb = solid:getBoundaries()
  local min = aabb.min
  local size = aabb:size()
  self.bumpWorld:add(solid,
                     min[1],
                     min[2],
                     size[1],
                     size[2])
  self.solids[solid] = true
end

function PhysicsWorld:destroySolid( solid )
  assert(self.solids[solid], 'Solids must be added before destoying them.')
  self.bumpWorld:remove(solid)
  self.solids[solid] = nil
  solid:destroy()
end

function PhysicsWorld:getSolidsAt( position, filter )
  return self.bumpWorld:queryPoint(position[1],
                                   position[2],
                                   filter)
end

function PhysicsWorld:getSolidsIn( aabb, filter )
  local min = aabb.min
  local size = aabb:size()
  return self.bumpWorld:queryRect(min[1],
                                  min[2],
                                  size[1],
                                  size[2],
                                  filter)
end

function PhysicsWorld:getSolidsAlong( lineStart, lineEnd, filter )
  return self.bumpWorld:querySegment(lineStart[1],
                                     lineStart[2],
                                     lineEnd[1],
                                     lineEnd[2],
                                     filter)
end

function PhysicsWorld:draw()
  if config:get('debug.collisionShapes.show') then
    for solid, _ in pairs(self.solids) do
      local boundaries = solid:getBoundaries()
      debugtools.drawAabb(boundaries, 'debug.collisionShapes.color')
    end
  end
end

return PhysicsWorld
