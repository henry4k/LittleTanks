local resources = {}

local function loadImage( fileName, ... )
  resources[fileName] = love.graphics.newImage(fileName, ...)
end

function resources.load()
  loadImage('littletanks/tiles.png')
  loadImage('littletanks/tiles-small.png')
  loadImage('littletanks/tank.png')
end

return resources
