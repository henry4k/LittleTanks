local class = require 'middleclass'


local AnimationDefinition = class('littletanks.AnimationDefinition')

function AnimationDefinition:initialize( options )
  assert(options.texture)
  assert(options.duration)

  self.texture = options.texture
  self.duration = options.duration

  self.fields = {}
  self.fieldIndexMap = {}
  self:addField('quad')
  for _, fieldName in ipairs(options.extraFields or {}) do
    self:_addField(fieldName)
  end

  self.frames = {}
  for _, frameDefinition in ipairs(options.frames or {}) do
    self:addFrame(frameDefinition)
  end
end

function AnimationDefinition:_addField( name )
  assert(not self.fieldIndexMap[name], 'Field has already been added.')
  local fields = self.fields
  fields[#fields+1] = name
  self.fieldIndexMap[name] = #fields
end

function AnimationDefinition:addFrame( frameDefinition )
  local frame = {}
  for fieldIndex, fieldName in ipairs(self.fields) do
    local fieldValue = frameDefinition[fieldName]
    assert(fieldValue, 'Frame is missing a field.')
    frame[fieldIndex] = fieldValue
  end
  self.frames[#self.frames+1] = frame
end

function AnimationDefinition:getFrameCount()
  return #self.frames
end

function AnimationDefinition:getFrameField( frameIndex, fieldName )
  local frame = self.frames[frameIndex]
  assert(frame, 'Frame doesn\'t exist.')

  local fieldIndex = self.fieldIndexMap[fieldName]
  assert(fieldIndex, 'No field with the given name.')

  return frame[fieldIndex]
end

return AnimationDefinition
