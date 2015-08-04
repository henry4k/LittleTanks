local userdataIdMap = {}
local highestUserdataId = 0

local function register( ud )
  assert(not userdataIdMap[ud], 'Userdata has already been registered.')
  highestUserdataId = highestUserdataId + 1
  userdataIdMap[ud] = highestUserdataId
end

local function unregister( ud )
  assert(userdataIdMap[ud], 'Userdata unknown')
  userdataIdMap[ud] = nil
end

local function getId( ud )
  return userdataIdMap[ud]
end

return { register   = register,
         unregister = unregister,
         getId = getId }
