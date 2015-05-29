local class = require 'middleclass'
local EventSource = require 'EventSource'


local Config = class('Config')
Config:include(EventSource)

function Config:initialize()
  self:initializeEventSource()
  self.variables = {}
end

function Config:destroy()
  self:destroyEventSource()
end

function Config:get( variableName )
  return self.variables[variableName]
end

function Config:set( variableName, value )
  local oldValue = self.variables[variableName]
  if value ~= oldValue then
    self.variables[variableName] = value
    self:fireEvent('variableChanged', variableName, value)
  end
end

function Config:toggle( variableName )
  local oldValue = self.variables[variableName]
  assert(oldValue == nil or
         oldValue == false or
         oldValue == true, 'Variable must be a boolean value.')
  if oldValue then
    self:set(variableName, true)
  else
    self:set(variableName, false)
  end
end

return Config()
