local gamera = require 'gamera'
local utils = require 'utils'
local TileMap = require 'lovegame.TileMap'
local RandomTile = require 'lovegame.RandomTile'
local TileMapView = require 'lovegame.TileMapView'


running = false
tilemap = nil
tilemapView = nil

function love.load()
  love.graphics.setDefaultFilter('linear', 'nearest')

  tilemap = TileMap{width=40,
                    height=30}

  local randomTile = RandomTile(3, 2)
  tilemap:registerTile(randomTile)

  local image = love.graphics.newImage('tiles.png')

  tilemapView = TileMapView(image, 16)
  tilemapView:update(tilemap, 10, 10, 20, 20)
end

function love.focus( hasFocus )
  if hasFocus then
    running = true
  else
    running = false
  end
end

function love.keypressed( key, isRepeat )
  if key == 'escape' then
    love.event.quit()
  end
end

function love.update( timeDelta )
  if not running then
    return
  end
end

function love.draw()
  tilemapView:draw()

  if not running then
    local x, y = utils.fractionToPixels(0.5, 0.5)
    love.graphics.printf('PAUSED', x, y, 0, 'center')
  end
end
