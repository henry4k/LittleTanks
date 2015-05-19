local utils = {}

function utils.framebufferSize()
  return love.window.fromPixels(love.window.getDimensions())
end

function utils.fractionToPixels( x, y )
  local w, h = utils.framebufferSize()
  return w*x, h*y
end

function utils.debugPrint( x, y, format, ... )
  local text = string.format(format, ...)
  love.graphics.print(text, x, y)
end

return utils
