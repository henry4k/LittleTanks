local resources = {}

local function loadImage( fileName, ... )
  resources[fileName] = love.graphics.newImage(fileName, ...)
end

function resources.load()
  loadImage('tiles.png')
  loadImage('tiles-small.png')
  loadImage('tank.png')
end

return resources
