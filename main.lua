local gamera = require 'gamera'
local utils = require 'utils'
local imagefont = require 'imagefont'
local TileMap = require 'lovegame.TileMap'
local LittleTank = require 'lovegame.LittleTank'


running = false
tilemap = nil
tilemapSpriteBatch = nil
littleTank = nil

function love.load()
  love.graphics.setDefaultFilter('linear', 'nearest')

  tilemap = TileMap{width=40,
                    height=30,
                    tileAtlasRows=3,
                    tileAtlasColumns=2}

  local image = love.graphics.newImage('tiles.png')
  tilemapSpriteBatch = love.graphics.newSpriteBatch(image)

  tilemap:fillSpriteBatch(tilemapSpriteBatch,
                          10, 10, 20, 20)

  local font = imagefont.load()
  love.graphics.setFont(font)

  littleTank = LittleTank()
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

  littleTank:update(timeDelta)
end

function love.draw()
  love.graphics.draw(tilemapSpriteBatch,
                     0, 0,
                     0,
                     16*3)

  littleTank:draw(10, 10, 0, 3)

  if not running then
    local x, y = utils.fractionToPixels(0.5, 0.5)
    love.graphics.printf('PAUSED', x, y, 0, 'center')
  end
end
