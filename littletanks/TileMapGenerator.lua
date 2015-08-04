local class = require 'middleclass'


local TileMapGenerator = class('littletanks.TileMapGenerator')

function TileMapGenerator:initialize( seed )
  self.randomGenerator = love.math.newRandomGenerator(seed)
  self.noiseZ = self.randomGenerator:random()
end

function TileMapGenerator:noise( position )
  return love.math.noise(position[1], position[2], self.noiseZ)
end

function TileMapGenerator:getTileAt( position )
  --[[
    - Biome
      - ???
  ]]
  return 1
end

return TileMapGenerator
