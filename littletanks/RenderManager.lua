local class = require 'middleclass'
--local sort  = require 'sort'
local UserdataRegistry = require 'littletanks.UserdataRegistry'


local RenderManager = class('littletanks.RenderManager')

function RenderManager:initialize()
  self.drawOperations = {}
  self.activeDrawOperations = 0
end

function RenderManager:destroy()
end

local blendModeOrderMap = {
    additive = 1,
    alpha    = 2,
    replace  = 3
}

local defaultBlendMode = 'alpha'
local defaultBlendModeOrder = blendModeOrderMap[defaultBlendMode]

local function defaultDrawFn( context, transformation )
  love.graphics.draw(context,
                     transformation.x,
                     transformation.y,
                     transformation.r,
                     transformation.sx,
                     transformation.sy)
end

function RenderManager:addDrawOperation( options )
  assert(options.layer, 'No layer given.')
  assert(options.texture, 'No texture given.')
  assert(options.renderArgs, 'No render arguments given.')

  local blendModeOrder = blendModeOrderMap[options.blendMode] or
                         defaultBlendModeOrder
  local shaderOrder  = UserdataRegistry.getId(options.shader)  or 0
  local textureOrder = UserdataRegistry.getId(options.texture) or 0

  local drawFn  = options.drawFn or defaultDrawFn
  local context = options.context

  local drawOperation = { layer     = options.layer,
                          blendMode = options.blendMode or defaultBlendMode,
                          shader    = options.shader,
                          texture   = options.texture,

                          blendModeOrder = blendModeOrder,
                          shaderOrder    = shaderOrder,
                          textureOrder   = textureOrder,

                          drawFn         = drawFn,
                          context        = context,
                          transformation = options.transformation }

  local activeDrawOperations = self.activeDrawOperations + 1
  self.activeDrawOperations = activeDrawOperations
  self.drawOperations[activeDrawOperations] = drawOperation

  assert(activeDrawOperations < 2000, 'Too many render operations queued.')
end

local function CompareDrawOperations( a, b )
    return a.layer          < b.layer or
           a.blendModeOrder < b.blendModeOrder or
           a.shaderOrder    < b.shaderOrder or
           a.textureOrder   < b.textureOrder
           -- TODO: or
           -- a.transformation.y < b.transformation.y or
           -- a.transformation.x < b.transformation.x
end

function RenderManager:flush()
  --table.shuffle(self.drawOperations)
  table.sort(self.drawOperations, CompareDrawOperations)
  --sort.insertion(self.drawOperations, CompareDrawOperations)

  local currentBlendMode = love.graphics.getBlendMode()
  local currentShader    = love.graphics.getShader()

  for _, drawOperation in ipairs(self.drawOperations) do

    if drawOperation.blendMode ~= currentBlendMode then
      love.graphics.setBlendMode(drawOperation.blendMode)
      currentBlendMode = drawOperation.blendMode
    end

    if drawOperation.shader ~= currentShader then
      --if drawable.shader then
        love.graphics.setShader(drawOperation.shader)
      --else
      --  love.graphics.setShader()
      --end
      currentShader = drawOperation.shader
    end

    drawOperation.drawFn(drawOperation.context, drawOperation.transformation)
    love.graphics.draw(unpack(drawOperation.drawParams))
  end

  self.activeDrawOperations = 0
end


return RenderManager
