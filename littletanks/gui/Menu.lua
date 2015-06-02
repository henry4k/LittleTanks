local class = require 'middleclass'
local Vector = require 'Vector'
local GUIEntry = require 'littletanks.gui.Entry'


local GUIMenu = class('littletanks.gui.Menu', GUIEntry)

function GUIMenu:initialize( name )
  GUIEntry.initialize(self, name)
  self.entries = {}
  self.entryMargin = 10
  self.selectedEntryIndex = nil
end

function GUIMenu:destroy()
  for _, entry in ipairs(self.entries) do
    entry:destroy()
  end
end

function GUIMenu:addEntry( entry )
  table.insert(self.entries, entry)
  if not self.selectedEntryIndex then
    self:selectEntry(#self.entries)
  end
end

function GUIMenu:update( timeDelta )
  for _, entry in ipairs(self.entries) do
    entry:update(timeDelta)
  end
end

function GUIMenu:getSize()
  local margin = self.entryMargin
  local size = Vector(0, 0)
  for _, entry in ipairs(self.entries) do
    local entrySize = entry:getSize()
    size[1] = math.max(size[1], entrySize[1])
    size[2] = size[2] + entrySize[2] + margin
  end
  size[2] = size[2] - margin
  return size
end

function GUIMenu:draw()
  local translate = love.graphics.translate
  local push      = love.graphics.push
  local pop       = love.graphics.pop

  local size = self:getSize()

  local margin = self.entryMargin
  local yOffset = -size[2]/2
  for _, entry in ipairs(self.entries) do
    local entrySize = entry:getSize()

    yOffset = yOffset + (entrySize[2]/2) -- move to center of entry

    push()
    translate(0, yOffset)
    entry:draw()
    pop()

    yOffset = yOffset + (entrySize[2]/2) + margin
  end
end

function GUIMenu:_getEntryByIndex( index )
  local entries = self.entries
  if index ~= nil and
     index >= 1 and
     index <= #entries then
     return entries[index]
  end
end

function GUIMenu:selectEntry( index )
  local entry = self:_getEntryByIndex(index)
  assert(entry, 'Index out of bounds.')

  local lastIndex = self.selectedEntryIndex
  local lastEntry = self:_getEntryByIndex(lastIndex)
  if lastEntry then
    lastEntry:onDeselection()
  end

  self.selectedEntryIndex = index
  entry:onSelection()
  self:setChildControllables({entry})
end

function GUIMenu:trySelectNextEntry()
  local entryIndex = self.selectedEntryIndex
  if entryIndex < #self.entries then
    self:selectEntry(entryIndex + 1)
  end
end

function GUIMenu:trySelectPreviousEntry()
  local entryIndex = self.selectedEntryIndex
  if entryIndex > 1 then
    self:selectEntry(entryIndex - 1)
  end
end

GUIMenu:mapControl('moveY', function( self, absolute, delta )
  if absolute > 0 then
    self:trySelectPreviousEntry()
  elseif absolute < 0 then
    self:trySelectNextEntry()
  end
end)

return GUIMenu
