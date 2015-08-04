local class = require 'middleclass'


local RenderContext = class('littletanks.RenderContext')

function RenderContext:initialize( renderManager )
  self.renderManager = renderManager

  self.transformationStack = {}
  self:pushTransformation()

  self.atlasImages = {}
end

function RenderContext:destroy()
end

local identityTransformation =
{
  x  = 0,
  y  = 0,
  r  = 0,
  sx = 1,
  sy = 1
}

function RenderContext:pushTransformation( x, y, r, sx, sy )
  x = x or 0
  y = y or 0
  r = r or 0
  sx = sx or 1
  sy = sy or sx or 1
  local stack = self.transformationStack
  local oldTransformation = stack[#stack] or identityTransformation
  stack[#stack+1] = { x  = oldTransformation.x  + x,
                      y  = oldTransformation.y  + y,
                      r  = oldTransformation.r  + r,
                      sx = oldTransformation.sx * sx,
                      sy = oldTransformation.sy * sy }
end

function RenderContext:popTransformation()
  local stack = self.transformationStack
  assert(#stack == 1, 'Can\'t pop last transformation from stack.')
  stack[#stack] = nil
end

function RenderContext:_getCurrentTransformation()
  local stack = self.transformationStack
  return stack[#stack]
end

function RenderContext:registerAtlasImage( name, atlasImage )
  assert(not self.atlasImages[name],
         'A atlas image with the given name has already been registered.')
  self.atlasImages[name] = atlasImage
end

local function quadDrawFn( context, transformation )
  love.graphics.draw(context[1],
                     context[2],
                     transformation.x,
                     transformation.y,
                     transformation.r,
                     transformation.sx,
                     transformation.sy)
end

function RenderContext:drawAtlasQuad( options )
  assert(options.atlasImage, 'Atlas image missing.')
  assert(options.quad, 'Quad missing.')
  local atlasImage = self.atlasImages[options.atlasImage]
  assert(atlasImage, 'No such atlas image.')
  local image = atlasImage.image
  local quad = atlasImage:getQuad(options.quad)

  options.texture = image
  options.quad = quad

  self:drawQuad(options)
end

function RenderContext:drawQuad( options )
  assert(options.texture, 'Texture missing.')
  assert(options.quad,    'Quad missing.')

  options.drawFn = quadDrawFn
  options.context = {options.texture, options.quad}

  self:draw(options)
end

function RenderContext:draw( options )
  options.transformation = options.transformation or
                           self:_getCurrentTransformation()
  self.renderManager:addDrawOperation(options)
end


return RenderContext
