local class = require 'middleclass'
local bump = require 'bump'
local Vector = require 'Vector'
local Aabb = require 'Aabb'
local debug2d = require 'debug2d'


local PhysicsWorld = class('littletanks.PhysicsWorld')

function PhysicsWorld:initialize( options )
  assert(options.cellSize and
         options.worldBoundaries)

  self.worldBoundaries = options.worldBoundaries
  self.bumpWorld = bump.newWorld(options.cellSize)
end

function PhysicsWorld:destroy()
  -- Nothing to do here (yet)
end

function PhysicsWorld:addSolid( solid, aabb )
  local min = aabb.min
  local size = aabb:size()
  self.bumpWorld:add(solid,
                     min[1],
                     min[2],
                     size[1],
                     size[2])
end

function PhysicsWorld:removeSolid( solid )
  self.bumpWorld:remove(solid)
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

return PhysicsWorld
