local class = require 'middleclass'
local config = require 'config'
local debugtools = require 'debugtools'


local PhysicsWorld = class('littletanks.PhysicsWorld')

function PhysicsWorld:initialize()
  self.solids = {}

  self.world = love.physics.newWorld()

  local function beginContact(...) self:_beginContact(...) end
  local function endContact(...)   self:_endContact(...)   end
  local function preSolve(...)     self:_preSolve(...)     end
  local function postSolve(...)    self:_postSolve(...)    end
  self.world:setCallbacks(beginContact, endContact, preSolve, postSolve)
end

function PhysicsWorld:destroy()
  for solid, _ in pairs(self.solids) do
    self:destroySolid(solid)
  end
  self.world:destroy()
end

function PhysicsWorld:update( timeDelta )
  self.world:update(timeDelta)
end

function PhysicsWorld:_beginContact( fixtureA, fixtureB, contact )
  --local solidA = fixtureA:getUserData()
  --local solidB = fixtureB:getUserData()
  --print('begin contact', fixtureA, fixtureB, contact)
end

function PhysicsWorld:_endContact( fixtureA, fixtureB, contact )
  --local solidA = fixtureA:getUserData()
  --local solidB = fixtureB:getUserData()
  --print('end contact', fixtureA, fixtureB, contact)
end

function PhysicsWorld:_preSolve( fixtureA, fixtureB, contact )
  --local solidA = fixtureA:getUserData()
  --local solidB = fixtureB:getUserData()
  --print('pre solve', fixtureA, fixtureB, contact)
end

function PhysicsWorld:_postSolve( fixtureA, fixtureB, contact,
                                  normalImpulse1, tangentImpulse1,
                                  normalImpulse2, tangentImpulse2)
  --local solidA = fixtureA:getUserData()
  --local solidB = fixtureB:getUserData()
  --print('post solve', fixtureA, fixtureB, contact)
end

function PhysicsWorld:addSolid( solid )
  assert(not self.solids[solid], 'Solid has already been added.')
  local body = love.physics.newBody(self.world)
  body:setFixedRotation(true)
  body:setLinearDamping(1) -- TODO: Should depend on:
                           --       - whether it is flying
                           --       - what kind of underground it is touching
                           --       - what kind of "tires" it is using
  solid:_setBody(body)
  self.solids[solid] = true
end

function PhysicsWorld:destroySolid( solid )
  assert(self.solids[solid], 'Solids must be added before destoying them.')
  self.solids[solid] = nil
  solid:destroy()
end

--[[ TODO
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
  local results = {}
  local callback = function( fixture,  )
  self.world:rayCast(lineStart[1],
                     lineStart[2],
                     lineEnd[1],
                     lineEnd[2],
                     callback)
end
]]

function PhysicsWorld:draw()
  if config:get('debug.collisionShapes.show') then
    for solid, _ in pairs(self.solids) do
      local body = solid._body
      for _, fixture in ipairs(body:getFixtureList()) do
        assert(fixture:getUserData() == solid)
        local shape = fixture:getShape()
        local shapeType = shape:getType()
        if shapeType == 'polygon' then
          debugtools.drawPolygon('debug.collisionShapes.color', body:getWorldPoints(shape:getPoints()))
        else
          error('Unknown shape type: '..shapeType)
        end
      end
    end
  end
end

return PhysicsWorld
