local class = require 'middleclass'
local Controllable = require 'Controllable'


local GUIEntry = class('littletanks.gui.Entry')
GUIEntry:include(Controllable)

function GUIEntry:initialize( name )
  self:initializeControllable()
  self.name = name
  self.selected = false
end

function GUIEntry:destroy()
  self:destroyControllable()
end

function GUIEntry:getSize()
  error('Missing implementation.')
end

function GUIEntry:update( timeDelta )
end

function GUIEntry:draw( origin )
  error('Missing implementation.')
end

function GUIEntry:onSelection()
  self.selected = true
end

function GUIEntry:onDeselection()
  self.selected = false
end

function GUIEntry:onControllablePushed()
end

function GUIEntry:onControllablePopped()
end

return GUIEntry
