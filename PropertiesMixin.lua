--- @mixin PropertiesMixin

local PropertiesMixin = {
  static = {
    getter = {},
    setter = {}
  }
}

--- Must be called by the including class in its constructor.
function PropertiesMixin:initializeProperties()
  local mt = getmetatable(self)
  self.originalIndex    = mt.__index
  self.originalNewIndex = mt.__newindex
  mt.__index    = self.__index
  mt.__newindex = self.__newindex
end

function PropertiesMixin:destroyProperties()
end

function PropertiesMixin:__index( key )
  local getter = self.class.getter[key]
  if getter then
    return getter(self, key)
  else
    --return self:originalIndex()
    return self.class.static[key]
  end
end

function PropertiesMixin:__newindex( key, value )
  local setter = self.class.setter[key]
  if setter then
    setter(self, key, value)
  else
    --return self:originalNewIndex(value)
    self.class.__instanceDict[key] = value
  end
end

return PropertiesMixin
