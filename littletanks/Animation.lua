local floor = math.floor
local ceil  = math.ceil
local class = require 'middleclass'
local mixLinear = require('mix').linear


local Animation = class('littletanks.Animation')

function Animation:initialize( definition )
  self.definition = definition
  self.time = 0
end

function Animation:update( timeDelta )
  self.time = self.time + timeDelta
end

function Animation:_getFrameIndices()
  local duration = self.definition.duration
  local time = self.time
  local frameCount = self.definition:getFrameCount()
  local frameDuration = duration / frameCount

  local totalFrame = time / frameDuration

  local currentFrame = floor(totalFrame) - 1
  currentFrame = ((currentFrame-1) % frameCount) + 1 -- loop frame

  local nextFrame = ceil(totalFrame) - 1
  nextFrame = ((nextFrame-1) % frameCount) + 1 -- loop frame

  local transition = totalFrame - floor(totalFrame)

  return currentFrame, nextFrame, transition
end

function Animation:getFrameField( name )
  local frameIndex = self:_getFrameIndices()
  return self.definition:getFrameField(frameIndex, name)
end

function Animation:getInterpolatedFrameField( name )
  local currentFrameIndex, nextFrameIndex, transition = self:_getFrameIndices()
  local definition = self.definition
  local currentValue = definition:getFrameField(currentFrameIndex, name)
  local nextValue    = definition:getFrameField(nextFrameIndex,    name)
  return mixLinear(currentValue, nextValue, transition)
end

function Animation:draw( renderContext )
  local texture = self.definition.texture
  local quad = self:getFrameField('quad')
  renderContext:drawQuad{texture=texture,
                         quad=quad}
end

return Animation
