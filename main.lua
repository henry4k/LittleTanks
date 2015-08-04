--jit.off()
--jit.flush()
--require 'luacov'
--local luatrace = require 'luatrace'

local PROBE = require 'PROBE'
local input = require 'input'
local control = require 'control'
local utils = require 'utils'
local config = require 'config'
local Vector = require 'Vector'
local Aabb = require 'Aabb'
local RenderManager = require 'littletanks.RenderManager'
local RenderContext = require 'littletanks.RenderContext'
local AtlasImage = require 'littletanks.AtlasImage'
local Camera = require 'littletanks.Camera'
local TileMap = require 'littletanks.TileMap'
local TileMapGenerator = require 'littletanks.TileMapGenerator'
local Tile = require 'littletanks.Tile'
local LazyTileMapView = require 'littletanks.LazyTileMapView'
local PhysicsWorld = require 'littletanks.PhysicsWorld'
local TileSolidManager = require 'littletanks.TileSolidManager'
local EntityManager = require 'littletanks.EntityManager'
local TankAI = require 'littletanks.TankAI'
--local GUIButton = require 'littletanks.gui.Button'
--local GUIMenu = require 'littletanks.gui.Menu'
--local GUIController = require 'littletanks.gui.Controller'

local Tank = require 'littletanks.Tank'

local resources = require 'littletanks.resources'
local imagefont = require 'imagefont'


function InitializeConfig()
  config:set('debug.collisionShapes.color',      Vector(0,1,0))
  config:set('debug.camera.visiblePixels.color', Vector(1,0,0))
  config:set('debug.camera.visibleTiles.color',  Vector(1,0,0))
  config:set('debug.camera.scale', 1)

  config:set('debug.collisionShapes.show', false)
  config:set('debug.fps', false)
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
  assert(atlasImage:getQuad('TankDriveNorth1') ~= nil)
  assert(atlasImage:getQuad('TankDriveNorth2') ~= nil)
  return atlasImage
end

function CreateTileAtlasImage()
  local atlasImage = AtlasImage(resources['littletanks/tiles.png'])
  atlasImage:setQuad('Ground', Aabb(0, 0, 16, 16))
  atlasImage:setQuad('Mountain', Aabb(16, 0, 16, 16))
  return atlasImage
end

function SpawnAiTank()
  local tileMapAabb = tileMap:getBoundaries()
  local tileMapPixels = tileMapView:tileToPixelAabb(tileMapAabb)
  local position = Vector(math.random(tileMapPixels.min[1],
                                      tileMapPixels.max[1]),
                          math.random(tileMapPixels.min[2],
                                      tileMapPixels.max[2]))

  local aiTank = Tank()
  aiTank.name = 'AI '..(#aiHoard+1)
  --aiTank:setChassis(SimpleTankChassis())
  --aiTank:setTurret(SimpleTankTurret())

  entityManager:addEntity(aiTank)
  aiTank:setPosition(position)

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

  local groundTile   = Tile{ quadName='Ground' }
  local mountainTile = Tile{ quadName='Mountain' }
  tileMap:registerTile(groundTile)
  tileMap:registerTile(mountainTile)

  tileMapView = LazyTileMapView{tileMap = tileMap,
                                atlasImage = CreateTileAtlasImage(),
                                tileWidth  = 16,
                                tileHeight = 16}
  tileMapView:setMargin(4)

  love.physics.setMeter(16)
  physicsWorld = PhysicsWorld()

  tileSolidManager = TileSolidManager{tileMap=tileMap,
                                      tileMapView=tileMapView,
                                      physicsWorld=physicsWorld}

  tileMap:setAt(Vector(23, 23), mountainTile)

  entityManager = EntityManager{physicsWorld=physicsWorld}

  camera = Camera{tileMap=tileMap,
                  tileMapView=tileMapView,
                  drawFn=DrawCameraView}

  renderManager = RenderManager()
  renderContext = RenderContext(renderManager)

  playerTank = Tank()
  playerTank.name = 'Player'
  --playerTank:setChassis(SimpleTankChassis())
  --playerTank:setTurret(SimpleTankTurret())

  entityManager:addEntity(playerTank)
  playerTank:setPosition(Vector(400, 400))
  control.pushControllable(playerTank)

  for i=1,10 do
    SpawnAiTank()
  end

  camera:setTargetPosition(Vector(10, 10), false)
  camera:setTargetEntity(playerTank, true)
  camera:setScale(2)
  camera:onWindowResize(Aabb(0, 0, love.graphics.getDimensions()))

  --SetupMenu()

  -- debug
  drawProbe = PROBE.new(60)
  drawProbe:hookAll(_G, 'draw', {love})
  drawProbe:enable()

  updateProbe = PROBE.new(60)
  updateProbe:hookAll(_G, 'update', {love})
  updateProbe:enable()
end

function love.quit()
  renderManager:destroy()
  camera:destroy()
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

  updateProbe:startCycle()
  for _, ai in ipairs(aiHoard) do
    ai:update(timeDelta)
  end
  --luatrace.tron()
  physicsWorld:update(timeDelta)
  entityManager:update(timeDelta)
  --luatrace.troff()
  camera:update(timeDelta)
  updateProbe:endCycle()
end

function DrawCameraView()
  tileMapView:draw(renderContext)
  entityManager:draw(renderContext)
  physicsWorld:draw(renderContext)
  renderManager:flush()
end

function love.draw()
  drawProbe:startCycle()
  camera:draw()
  --guiController:draw(Vector(love.graphics.getDimensions()))
  drawProbe:endCycle()
  drawProbe:draw(20, 20, 150, 560, 'DRAW CYCLE')
  updateProbe:draw(630, 20, 150, 560, 'UPDATE CYCLE')

  if not running then
    local x, y = utils.fractionToPixels(0.5, 0.5)
    love.graphics.printf('PAUSED', x, y, 0, 'center')
  end

  if config:get('debug.fps') then
    local fpsText = string.format('%d FPS',
                                  love.timer.getFPS())
    love.graphics.print(fpsText, 10, 10)
  end
end
