local class = require 'middleclass'


local TankTurret = class('littletanks.TankTurret')

function TankTurret:initialize()
end

function TankTurret:destroy()
  -- Nothing to do here (yet)
end

function TankTurret:update( timeDelta )
  -- Nothing to do here (yet).
end

function TankTurret:draw()
  error('Missing implementation.')
end

return TankTurret
