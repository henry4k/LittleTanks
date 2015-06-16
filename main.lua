--jit.off()
--jit.flush()
--require 'luacov'
--local luatrace = require 'luatrace'

local input = require 'input'
local control = require 'control'
local utils = require 'utils'
local config = require 'config'
local Vector = require 'Vector'
local Aabb = require 'Aabb'
local AtlasImage = require 'littletanks.AtlasImage'
local Camera = require 'littletanks.Camera'
local TileMap = require 'littletanks.TileMap'
local TileMapGenerator = require 'littletanks.TileMapGenerator'
local Tile = require 'littletanks.Tile'
local LazyTileMapView = require 'littletanks.LazyTileMapView'
local PhysicsWorld = require 'littletanks.PhysicsWorld'
local TileSolidManager = require 'littletanks.TileSolidManager'
local EntityView = require 'littletanks.EntityView'
local EntityManager = require 'littletanks.EntityManager'
local TankAI = require 'littletanks.TankAI'
--local GUIButton = require 'littletanks.gui.Button'
--local GUIMenu = require 'littletanks.gui.Menu'
--local GUIController = require 'littletanks.gui.Controller'

local Tank = require 'littletanks.Tank'
local SimpleTankChassis = require 'littletanks.SimpleTankChassis'
local SimpleTankTurret = require 'littletanks.SimpleTankTurret'

local resources = require 'littletanks.resources'
local imagefont = require 'imagefont'


function InitializeConfig()
  config:set('debug.collisionShapes.color',      Vector(0,1,0))
  config:set('debug.camera.visiblePixels.color', Vector(1,0,0))
  config:set('debug.camera.visibleTiles.color',  Vector(1,0,0))
  config:set('debug.camera.scale', 1)

  --config:set('debug.collisionShapes.show', true)
end
InitializeConfig()

running = false
camera = nil
tileMap = nil
tileMapView = nil
physicsWorld = nil
tileSolidManager = nil
entityManager = nil
aiHoard = {}
playerTank = nil

function CreateEntityAtlasImage()
  local atlasImage = AtlasImage(resources['littletanks/entities.png'])
  atlasImage:setQuadStrip('TankDriveNorth', Aabb(0, 0, 16, 16), 2)
  assert(atlasImage:getQuad('TankDriveNorth1'))
  assert(atlasImage:getQuad('TankDriveNorth2'))
  return atlasImage
end

function SpawnAiTank()
  local worldBoundaries = physicsWorld.worldBoundaries
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
  love.graphics.setFont(imagefont.load())

  input.bindVirtualAxis('a', 'd', 'moveX')
  input.bindVirtualAxis('s', 'w', 'moveY')
  input.bind('f', 'fire')

  local tileMapGenerator = TileMapGenerator(1) -- seed

  tileMap = TileMap{size=Vector(40, 40),
                    generator=tileMapGenerator}

  local groundTile   = Tile{ atlasX=1, atlasY=1 }
  local mountainTile = Tile{ atlasX=2, atlasY=1 }
  tileMap:registerTile(groundTile)
  tileMap:registerTile(mountainTile)

  tileMapView = LazyTileMapView{tileMap = tileMap,
                                image = resources['littletanks/tiles.png'],
                                tileWidth = 16,
                                tileHeight = 16}
  tileMapView:setMargin(4)

  local tileMapAabb = tileMap:getBoundaries()
  local tileMapPixels = tileMapView:tileToPixelAabb(tileMapAabb)

  physicsWorld = PhysicsWorld{cellSize=16*1,
                              worldBoundaries=tileMapPixels}
  -- Cell size should be a multiple of the tile size.
  -- In dense scenarios this should stick to 1,
  -- in sparse scenarios it can be larger.

  tileSolidManager = TileSolidManager{tileMap=tileMap,
                                      tileMapView=tileMapView,
                                      physicsWorld=physicsWorld}

  tileMap:setAt(Vector(23, 23), mountainTile)

  entityManager = EntityManager{physicsWorld=physicsWorld}

  local entityView = EntityView{entityManager=entityManager,
                                atlasImage=CreateEntityAtlasImage()}

  camera = Camera{tileMap=tileMap,
                  tileMapView=tileMapView,
                  entityView=entityView}

  playerTank = Tank()
  playerTank.name = 'Player'
  playerTank:setChassis(SimpleTankChassis())
  playerTank:setTurret(SimpleTankTurret())

  playerTank:teleportTo(Vector(400, 400))
  entityManager:addEntity(playerTank)
  control.pushControllable(playerTank)

  --for i=1,5 do
  --  SpawnAiTank()
  --end

  camera:setTargetPosition(Vector(10, 10), false)
  camera:setTargetEntity(playerTank, true)
  camera:setScale(2)
  camera:onWindowResize(Aabb(0, 0, love.graphics.getDimensions()))

  SetupMenu()
end

function love.quit()
  entityManager:destroy()
  tileSolidManager:destroy()
  physicsWorld:destroy()
  tileMapView:destroy()
  tileMap:destroy()
end

function love.resize()
  camera:onWindowResize(Aabb(0, 0, love.graphics.getDimensions()))
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
  --luatrace.tron()
  entityManager:update(timeDelta)
  --luatrace.troff()
  camera:update(timeDelta)
end

function DRAW_DEBUG_STUFF()
  entityManager:draw()
  physicsWorld:draw()
end

function love.draw()
  camera:draw()
  guiController:draw(Vector(love.graphics.getDimensions()))

  if not running then
    local x, y = utils.fractionToPixels(0.5, 0.5)
    love.graphics.printf('PAUSED', x, y, 0, 'center')
  end
end
