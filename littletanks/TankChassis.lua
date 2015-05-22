local class = require 'middleclass'
local Vector = require 'Vector'


local TankChassis = class('littletanks.TankChassis')

function TankChassis:initialize()
  self.turretAttachmentPoint = Vector(0, 0)
end

function TankChassis:destroy()
  -- Nothing to do here (yet)
end

function TankChassis:update( timeDelta )
  -- Nothing to do here (yet).
end

function TankChassis:draw()
  error('Missing implementation.')
end

return TankChassis
