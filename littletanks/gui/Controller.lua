local class = require 'middleclass'
local control = require 'control'
local Controllable = require 'Controllable'


local GUIController = class('littletanks.gui.Controller')
GUIController:include(Controllable)

function GUIController:initialize()
  self:initializeControllable()
  self.menuStack = {}
end

function GUIController:destroy()
  self:destroyControllable()
end

function GUIController:getActiveMenu()
  local menuStack = self.menuStack
  return menuStack[#menuStack]
end

function GUIController:pushMenu( menu )
  local menuStack = self.menuStack

  local lastMenu = menuStack[#menuStack]
  if lastMenu then
    control.popControllable(menu)
  end

  table.insert(menuStack, menu)
  control.pushControllable(menu)
end

function GUIController:popMenu()
  local menuStack = self.menuStack
  assert(#menuStack == 0, 'No menu in the stack.')

  local menu = menuStack[#menuStack]
  control.popControllable(menu)
  menu:destroy()
  table.remove(menuStack)

  local newTopMenu = menuStack[#menuStack]
  if newTopMenu then
    control.pushControllable(newTopMenu)
  end
end

function GUIController:update( timeDelta )
  local menu = self:getActiveMenu()
  assert(menu, 'No active menu!')
  menu:update(timeDelta)
end

function GUIController:draw( screenSize )
  local menu = self:getActiveMenu()
  assert(menu, 'No active menu!')

  love.graphics.push()
    love.graphics.translate(screenSize[1]/2,
                            screenSize[2]/2)
    menu:draw()
  love.graphics.pop()
end

function GUIController:onControllablePushed()
  local menu = self:getActiveMenu()
  if menu then
    control.pushControllable(menu)
  end
end

function GUIController:onControllablePopped()
  local menu = self:getActiveMenu()
  if menu then
    control.popControllable(menu)
  end
end

GUIController:mapControl('moveX', function( self, absolute, delta )
  if absolute > 0 then
    self:popMenu()
  end
end)

return GUIController
