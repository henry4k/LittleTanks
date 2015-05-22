local input = require 'input'
local control = require 'control'
local utils = require 'utils'
local Vector = require 'Vector'
local Aabb = require 'Aabb'
local Camera = require 'littletanks.Camera'
local TileMap = require 'littletanks.TileMap'
local RandomTile = require 'littletanks.RandomTile'
local LazyTileMapView = require 'littletanks.LazyTileMapView'

local Tank = require 'littletanks.Tank'
local SimpleTankChassis = require 'littletanks.SimpleTankChassis'
local SimpleTankTurret = require 'littletanks.SimpleTankTurret'

local resources = require 'littletanks.resources'
local debug2d = require 'debug2d'


running = false
camera = nil
tileMap = nil
tileMapView = nil
tank = nil

function love.load()
  love.graphics.setDefaultFilter('linear', 'nearest')
  resources.load()

  input.bindVirtualAxis('a', 'd', 'moveX')
  input.bindVirtualAxis('s', 'w', 'moveY')

  tileMap = TileMap{width=40,
                    height=40}

  local randomTile = RandomTile(3, 2)
  tileMap:registerTile(randomTile)

  tileMapView = LazyTileMapView(resources['littletanks/tiles.png'], 16)
  tileMapView:setMargin(4)

  camera = Camera{tileMap=tileMap,
                  tileMapView=tileMapView}

  tank = Tank()
  tank:setChassis(SimpleTankChassis())
  tank:setTurret(SimpleTankTurret())

  control.pushControllable(tank)

  tank.position = Vector(400, 400)

  camera:setTargetPosition(10, 10, false)
  camera:setTargetEntity(tank, true)
  camera.camera:setScale(1)

  local w, h = love.graphics.getDimensions()
  camera.camera:setWindow(w*.25, h*.25, w*.5, h*.5)
end

function love.quit()
  tileMap:destroy()
  tileMapView:destroy()
  tank:destroy()
end

function love.resize()
  --camera:setWindow(0, 0, love.graphics.getDimensions())
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
  camera:update(timeDelta)
end

function DRAW_DEBUG_STUFF()
  tank:draw()
  debug2d.drawAabbs()
end

function love.draw()

  local w, h = love.graphics.getDimensions()
  love.graphics.setColor(0, 128, 255)
  love.graphics.setLineWidth(4)
  love.graphics.rectangle('line', w*.25, h*.25, w*.5, h*.5)
  love.graphics.setLineWidth(1)
  love.graphics.setColor(255, 255, 255)

  camera:draw()

  debug2d.drawText()

  if not running then
    local x, y = utils.fractionToPixels(0.5, 0.5)
    love.graphics.printf('PAUSED', x, y, 0, 'center')
  end
end
