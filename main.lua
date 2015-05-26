local input = require 'input'
local control = require 'control'
local utils = require 'utils'
local Vector = require 'Vector'
local Aabb = require 'Aabb'
local Camera = require 'littletanks.Camera'
local TileMap = require 'littletanks.TileMap'
local RandomTile = require 'littletanks.RandomTile'
local LazyTileMapView = require 'littletanks.LazyTileMapView'
local EntityManager = require 'littletanks.EntityManager'
local TankAI = require 'littletanks.TankAI'

local Tank = require 'littletanks.Tank'
local SimpleTankChassis = require 'littletanks.SimpleTankChassis'
local SimpleTankTurret = require 'littletanks.SimpleTankTurret'

local resources = require 'littletanks.resources'
local debug2d = require 'debug2d'


running = false
camera = nil
tileMap = nil
tileMapView = nil
entityManager = nil
aiHoard = {}
playerTank = nil

function SpawnAiTank()
  local worldBoundaries = entityManager.worldBoundaries
  local position = Vector(math.random(worldBoundaries.min[1],
                                      worldBoundaries.max[1]),
                          math.random(worldBoundaries.min[2],
                                      worldBoundaries.max[2]))

  local aiTank = Tank()
  aiTank.name = 'AI '..(#aiHoard+1)
  aiTank:setChassis(SimpleTankChassis())
  aiTank:setTurret(SimpleTankTurret())

  aiTank:teleportTo(position)
  entityManager:addEntity(aiTank)

  local ai = TankAI(aiTank)
  ai:setTargetEntity(playerTank)

  table.insert(aiHoard, ai)
end

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

  local tileMapAabb = tileMap:getBoundaries()
  local tileMapPixels = tileMapView:tileToPixelAabb(tileMapAabb)

  entityManager = EntityManager{worldBoundaries=tileMapPixels,
                                cellSize=32}

  playerTank = Tank()
  playerTank.name = 'Player'
  playerTank:setChassis(SimpleTankChassis())
  playerTank:setTurret(SimpleTankTurret())

  playerTank:teleportTo(Vector(400, 400))
  entityManager:addEntity(playerTank)
  control.pushControllable(playerTank)

  SpawnAiTank()

  camera:setTargetPosition(10, 10, false)
  camera:setTargetEntity(playerTank, true)
  camera.camera:setScale(2)

  local w, h = love.graphics.getDimensions()
  camera.camera:setWindow(w*.25, h*.25, w*.5, h*.5)
end

function love.quit()
  entityManager:destroy()
  tileMapView:destroy()
  tileMap:destroy()
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

  for _, ai in ipairs(aiHoard) do
    ai:update(timeDelta)
  end
  entityManager:update(timeDelta)
  camera:update(timeDelta)
end

function DRAW_DEBUG_STUFF()
  entityManager:draw()
  debug2d.drawAabbs()
end

function love.draw()
  camera:draw()
  debug2d.drawText()

  if not running then
    local x, y = utils.fractionToPixels(0.5, 0.5)
    love.graphics.printf('PAUSED', x, y, 0, 'center')
  end
end
