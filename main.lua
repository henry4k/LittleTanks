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
local GUIButton = require 'littletanks.gui.Button'
local GUIMenu = require 'littletanks.gui.Menu'
local GUIController = require 'littletanks.gui.Controller'

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

function SetupMenu()
  guiController = GUIController()
  control.pushControllable(guiController)

  local menu = GUIMenu('Das Menue')
  menu:addEntry(GUIButton('Button 1', 'Button1 pressed', print))
  menu:addEntry(GUIButton('Button 2', 'Button2 pressed', print))
  menu:addEntry(GUIButton('Button 3', 'Button3 pressed', print))

  guiController:pushMenu(menu)
end

function SetupFrames()
  local texture = resources['littletanks/gui.png']
  texturedFrame = TexturedFrame{textureSize = Vector(texture:getDimensions()),
                                outerFrame = Aabb(10, 10, 50, 50),
                                innerFrame = Aabb(20, 20, 40, 40),
                                stretch = false}
  frameSpriteBatch = love.graphics.newSpriteBatch(texture)
  texturedFrame:generate(frameSpriteBatch, Aabb(100, 100, 150, 150))
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
  aiTank:setChassis(SimpleTankChassis())
  aiTank:setTurret(SimpleTankTurret())

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

  local groundTile   = Tile{ atlasX=1, atlasY=1 }
  local mountainTile = Tile{ atlasX=2, atlasY=1 }
  tileMap:registerTile(groundTile)
  tileMap:registerTile(mountainTile)

  tileMapView = LazyTileMapView{tileMap = tileMap,
                                image = resources['littletanks/tiles.png'],
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

  local tileMapAabb = tileMap:getBoundaries()
  local worldBoundaries = tileMapView:tileToPixelAabb(tileMapAabb)

  camera = Camera{drawFn=DrawCameraView,
                  worldBoundaries=worldBoundaries}

  playerTank = Tank()
  playerTank.name = 'Player'
  playerTank:setChassis(SimpleTankChassis())
  playerTank:setTurret(SimpleTankTurret())

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

function DrawCameraView( visiblePixels )
  local visibleTiles = tileMapView:pixelToTileAabb(visiblePixels, 'outer')
  tileMapView:set(visibleTiles)

  tileMapView:draw()
  entityManager:draw()
  physicsWorld:draw()

  if config:get('debug.camera.visibleTiles.show') then
    local visibleTilesPixels = tileMapView:tileToPixelAabb(visibleTiles)
    debugtools.drawAabb(visibleTilesPixels, 'debug.camera.visibleTiles.color')
  end
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
