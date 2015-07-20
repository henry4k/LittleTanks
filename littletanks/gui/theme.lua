local Vector = require 'Vector'
local Aabb = require 'Aabb'
local resources = require 'littletanks.resources'
local TexturedFrame = require 'littletanks.TexturedFrame'


local theme = {}

theme.minFrameWidth = 100

function theme.initialize()
  local image = resources['littletanks/gui.png']

  theme.spriteBatch = love.graphics.newSpriteBatch(image)


  local imageSize = Vector(image:getDimensions())

  theme.defaultFrame =
    TexturedFrame{outerFrame = Aabb( 0,  0, 30, 30),
                  innerFrame = Aabb(10, 10, 20, 20),
                  textureSize = imageSize}

  theme.selectedFrame =
    TexturedFrame{outerFrame = Aabb(30,  0, 60, 30),
                  innerFrame = Aabb(40, 10, 50, 20),
                  textureSize = imageSize}

  theme.activeFrame =
    TexturedFrame{outerFrame = Aabb(60,  0, 90, 30),
                  innerFrame = Aabb(70, 10, 80, 20),
                  textureSize = imageSize}
end

function theme.generateFrame( name, position, size )
  size = Vector(math.min(size[1], theme.minFrameWidth),
                size[2])
  local aabb = Aabb(position - size/2,
                    position + size/2)

  local frame = theme[name..'Frame'] -- Magic .. ugh
  frame:generate(theme.spriteBatch, aabb)
end

return theme
