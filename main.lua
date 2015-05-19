local gamera = require 'gamera'
local input = require 'input'
local control = require 'control'
local utils = require 'utils'
local Vector = require 'Vector'
local TileMap = require 'lovegame.TileMap'
local RandomTile = require 'lovegame.RandomTile'
local TileMapView = require 'lovegame.TileMapView'

local Tank = require 'lovegame.Tank'
local SimpleTankChassis = require 'lovegame.SimpleTankChassis'
local SimpleTankTurret = require 'lovegame.SimpleTankTurret'


running = false
tilemap = nil
tilemapView = nil
tank = nil

local resources = {}

local function LoadImage( fileName, ... )
  assert(not resources[fileName], 'Resource already loaded.')
  resources[fileName] = love.graphics.newImage(fileName, ...)
end

function love.load()
  love.graphics.setDefaultFilter('linear', 'nearest')

  input.bindVirtualAxis('a', 'd', 'moveX')
  input.bindVirtualAxis('s', 'w', 'moveY')

  LoadImage('tiles.png')

  tilemap = TileMap{width=40,
                    height=30}

  local randomTile = RandomTile(3, 2)
  tilemap:registerTile(randomTile)

  tilemapView = TileMapView(resources['tiles.png'], 16)
  tilemapView:set(tilemap, 10, 10, 20, 20)

  tank = Tank()
  tank:setChassis(SimpleTankChassis())
  tank:setTurret(SimpleTankTurret())

  control.pushControllable(tank)

  tank.position = Vector(10, 10)
end

function love.quit()
  tilemap:destroy()
  tilemapView:destroy()
  tank:destroy()
end

function love.focus( hasFocus )
  if hasFocus then
    running = true
  else
    running = false
  end
end

function love.update( timeDelta )
  if not running then
    return
  end

  tank:update(timeDelta)
end

function love.draw()
  tilemapView:draw()
  tank:draw()

  if not running then
    local x, y = utils.fractionToPixels(0.5, 0.5)
    love.graphics.printf('PAUSED', x, y, 0, 'center')
  end
end
