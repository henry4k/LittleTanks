local class = require 'middleclass'


local EntityRenderContext = class('littletanks.EntityRenderContext')

function EntityRenderContext:initialize( spriteBatch, atlasImage )
  self.spriteBatch = spriteBatch
  self.atlasImage = atlasImage
end

function EntityRenderContext:addQuad( name, ... )
  local quad = self.atlasImage:getQuad(name)
  self.spriteBatch:add(quad, ...)
end
