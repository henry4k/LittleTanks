local control = require 'control'


local input = {
  inputHandlers = {}
}

function input.bind( inputName, controlName, factor )
  input.inputHandlers[inputName] = { controlName = controlName,
                                     factor = factor or 1 }
end

function input.bindVirtualAxis( minInputName, maxInputName, controlName )
  input.bind(minInputName, controlName, -1)
  input.bind(maxInputName, controlName,  1)
end

function input.processAction( name, absolute, delta )
  local handler = input.inputHandlers[name]
  if handler then
    control.processControlAction(handler.controlName,
                                 absolute * handler.factor,
                                 delta * handler.factor)
  end
end


--- Bindings: ---

function love.keypressed( key, isRepeat )
  if isRepeat == true then return end
  input.processAction(key, 1, 1)

  if key == 'escape' then
    love.event.quit()
  end
end

function love.keyreleased( key )
  input.processAction(key, 0, -1)
end

function love.mousepressed( x, y, button )
  input.processAction('mousebutton'..button, 1, 1)
end

function love.mousereleased( x, y, button )
  input.processAction('mousebutton'..button, 0, -1)
end

----------------

return input
