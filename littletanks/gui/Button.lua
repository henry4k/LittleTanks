local class = require 'middleclass'
local Vector = require 'Vector'
local GUIEntry = require 'littletanks.gui.Entry'


local GUIButton = class('littletanks.gui.Button', GUIEntry)

function GUIButton:initialize( name, callbackContext, callbackFunction )
  GUIEntry.initialize(self, name)
  self.callbackContext = callbackContext
  self.callbackFunction = callbackFunction
  self.pressed = false
  self:setLabel(name)
end

function GUIButton:setLabel( label, effect )
  effect = effect or ''
  label = ('%s%s%s'):format(effect, label, effect)
  self.label = label

  local font = love.graphics.getFont()
  self.size = Vector(font:getWidth(label),
                     font:getHeight())
end

function GUIButton:getSize()
  return self.size
end

function GUIButton:draw( origin )
  local size = self.size
  love.graphics.print(self.label, -size[1]/2, -size[2]/2)
end

function GUIButton:activate()
  self.callbackFunction(self.callbackContext)
end

function GUIButton:_getEffect() -- temp!
  if self.pressed and self.selected then
    return '!'
  elseif self.pressed then
    return 'X'
  elseif self.selected then
    return '*'
  else
    return ''
  end
end

function GUIButton:onSelection()
  GUIEntry.onSelection(self)
  self:setLabel(self.name, self:_getEffect())
end

function GUIButton:onDeselection()
  GUIEntry.onDeselection(self)
  self:setLabel(self.name, self:_getEffect())
end

GUIButton:mapControl('fire', function( self, absolute, delta )
  if absolute > 0 then
    self:activate()
    self.pressed = true
  else
    self.pressed = false
  end
  self:setLabel(self.name, self:_getEffect())
end)

return GUIButton
