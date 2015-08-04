local class = require 'middleclass'
local Vector = require 'Vector'


local TexturedFrame = class('littletanks.TexturedFrame')

function TexturedFrame:initialize( options )
  assert(options.outerFrame and
         options.innerFrame)

  local outerFrame  = options.outerFrame
  local innerFrame  = options.innerFrame
  local textureSize = options.textureSize or Vector(1, 1)
  self.stretch = options.stretch or false

  assert(outerFrame.min:componentsGreaterOrEqualTo(Vector(0, 0)) and
         outerFrame.max:componentsLesserOrEqualTo(textureSize),
         'Frame doesn\'t fit in the atlas texture.')
  assert(outerFrame:contains(innerFrame),
         'Inner frame is too large.')

  self.outerFrame = outerFrame
  self.innerFrame = innerFrame

  self:_buildSubFrames(outerFrame, innerFrame, textureSize)
end

local function createSubFrame( start, size, textureSize )
  return { start = start,
           size = size,
           textureSize = textureSize, -- Meeh
           quad = love.graphics.newQuad(start[1],
                                        start[2],
                                        size[1],
                                        size[2],
                                        textureSize[1],
                                        textureSize[2]) }
end

function TexturedFrame:_buildSubFrames( outerFrame, innerFrame, textureSize )
  local innerFrameSize = innerFrame:size()

  -- top left
  local topLeftSize = innerFrame.min - outerFrame.min
  local topLeftStart = outerFrame.min
  self.topLeft = createSubFrame(topLeftStart, topLeftSize, textureSize)

  -- top center
  local topCenterSize = Vector(innerFrameSize[1],
                               topLeftSize[2])
  local topCenterStart = Vector(innerFrame.min[1],
                                outerFrame.min[2])
  self.topCenter = createSubFrame(topCenterStart, topCenterSize, textureSize)

  -- top right
  local topRightSize = Vector(outerFrame.max[1] - innerFrame.max[1],
                              topLeftSize[2])
  local topRightStart = Vector(innerFrame.max[1],
                               outerFrame.min[2])
  self.topRight = createSubFrame(topRightStart, topRightSize, textureSize)

  -- center right
  local centerRightSize = Vector(topRightSize[1],
                                 innerFrameSize[2])
  local centerRightStart = Vector(innerFrame.max[1],
                                  innerFrame.max[2] - centerRightSize[2])
  self.centerRight = createSubFrame(centerRightStart, centerRightSize, textureSize)

  -- bottom right
  local bottomRightSize = outerFrame.max - innerFrame.max
  local bottomRightStart = outerFrame.max - bottomRightSize
  self.bottomRight = createSubFrame(bottomRightStart, bottomRightSize, textureSize)

  -- bottom center
  local bottomCenterSize = Vector(innerFrameSize[1],
                                  bottomRightSize[2])
  local bottomCenterStart = Vector(innerFrame.min[1],
                                   innerFrame.max[2])
  self.bottomCenter = createSubFrame(bottomCenterStart, bottomCenterSize, textureSize)

  -- bottom left
  local bottomLeftSize = Vector(topLeftSize[1],
                                bottomRightSize[2])
  local bottomLeftStart = Vector(outerFrame.min[1],
                                 innerFrame.max[2])
  self.bottomLeft = createSubFrame(bottomLeftStart, bottomLeftSize, textureSize)

  -- center left
  local centerLeftSize = Vector(topLeftSize[1],
                                innerFrameSize[2])
  local centerLeftStart = Vector(outerFrame.min[1],
                                 innerFrame.min[2])
  self.centerLeft = createSubFrame(centerLeftStart, centerLeftSize, textureSize)

  -- center
  local centerSize = innerFrameSize
  local centerStart = innerFrame.min
  self.center = createSubFrame(centerStart, centerSize, textureSize)
end

local function repeatSubFrame( spriteBatch, subFrame, x, y, w, h )
  local min = math.min
  local newQuad = love.graphics.newQuad

  local position = Vector(x, y)
  local size = Vector(w, h)
  local lastQuadStart = position + (size / subFrame.size):floor() * subFrame.size

  local endPosition = position + size

  for quadY = y, lastQuadStart[2], subFrame.size[2] do
  for quadX = x, lastQuadStart[1], subFrame.size[1] do
    local quadSize = Vector(min(endPosition[1]-quadX, subFrame.size[1]),
                            min(endPosition[2]-quadY, subFrame.size[2]))

    if quadSize == subFrame.size then
      spriteBatch:add(subFrame.quad, quadX, quadY)
    else
      local quad = newQuad(subFrame.start[1],
                           subFrame.start[2],
                           quadSize[1],
                           quadSize[2],
                           subFrame.textureSize[1],
                           subFrame.textureSize[2])
      spriteBatch:add(quad, quadX, quadY)
    end
  end
  end
end

local function stretchSubFrame( spriteBatch, subFrame, x, y, w, h )
  spriteBatch:add(subFrame.quad,
                  x,
                  y,
                  0,
                  w / subFrame.size[1],
                  h / subFrame.size[2])
end

function TexturedFrame:generate( spriteBatch, aabb )
  local topLeft      = self.topLeft
  local topCenter    = self.topCenter
  local topRight     = self.topRight
  local centerRight  = self.centerRight
  local bottomRight  = self.bottomRight
  local bottomCenter = self.bottomCenter
  local bottomLeft   = self.bottomLeft
  local centerLeft   = self.centerLeft
  local center       = self.center

  spriteBatch:add(topLeft.quad,
                  aabb.min[1] - topLeft.size[1],
                  aabb.min[2] - topLeft.size[2])
  spriteBatch:add(topRight.quad,
                  aabb.max[1],
                  aabb.min[2] - topRight.size[2])
  spriteBatch:add(bottomRight.quad,
                  aabb.max[1],
                  aabb.max[2])
  spriteBatch:add(bottomLeft.quad,
                  aabb.min[1] - bottomLeft.size[1],
                  aabb.max[2])

  local generateSubFrame
  if self.stretch then
    generateSubFrame = stretchSubFrame
  else
    generateSubFrame = repeatSubFrame
  end

  local aabbSize = aabb:size()

  generateSubFrame(spriteBatch,
                   center,
                   aabb.min[1],
                   aabb.min[2],
                   aabbSize[1],
                   aabbSize[2])

  generateSubFrame(spriteBatch,
                   topCenter,
                   aabb.min[1],
                   aabb.min[2] - topCenter.size[2],
                   aabbSize[1],
                   topCenter.size[2])

  generateSubFrame(spriteBatch,
                   centerRight,
                   aabb.max[1],
                   aabb.min[2],
                   centerRight.size[1],
                   aabbSize[2])

  generateSubFrame(spriteBatch,
                  bottomCenter,
                  aabb.min[1],
                  aabb.max[2],
                  aabbSize[1],
                  bottomCenter.size[2])

  generateSubFrame(spriteBatch,
                   centerLeft,
                   aabb.min[1] - centerLeft.size[1],
                   aabb.min[2],
                   centerLeft.size[1],
                   aabbSize[2])
end

return TexturedFrame
