local class = require 'middleclass'
local Vector = require 'Vector'


local Solid = class('littletanks.Solid')

function Solid:initialize()
end

function Solid:destroy()
  if self._body then
    local body = self._body
    for _, fixture in ipairs(body:getFixtureList()) do
      fixture:destroy()
    end
    body:destroy()
  end
end

function Solid:_setBody( body )
  self._body = body
  self:onInitializeBody()
  assert(#body:getFixtureList() > 0, 'Add at least one shape to a body.')
  -- TODO: Check collision categories here.
end

function Solid:onInitializeBody()
  -- Nothing to do here (yet)
end

function Solid:_addShape( shape )
  assert(self._body, 'Add to physics world first.')
  local fixture = love.physics.newFixture(self._body, shape)
  fixture:setUserData(self)
end

function Solid:getPosition()
  assert(self._body, 'Add to physics world first.')
  return Vector(self._body:getPosition())
end

function Solid:setPosition( position )
  assert(self._body, 'Add to physics world first.')
  self._body:setPosition(position:unpack(2))
end

function Solid:onCollision( collision )
  -- Nothing to do here (yet)
end

return Solid
