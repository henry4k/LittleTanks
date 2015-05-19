local class = require 'middleclass'


local Tile = class('lovegame.Tile')

function Tile:initialize()
  self.id = math.random(1, 3*2)
end

return Tile
