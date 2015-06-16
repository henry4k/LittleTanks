local class = require 'middleclass'
local EntityRenderContext = require 'littletanks.EntityRenderContext'


local EntityView = class('littletanks.EntityView')

function EntityView:initialize( options )
  local atlasImage = options.atlasImage

  assert(atlasImage)

  self.atlasImage = atlasImage
  self.spriteBatch = love.graphics.newSpriteBatch(atlasImage.image)
end

function EntityView:destroy()
end

function EntityView:set( entityManager, aabb )
  local entities = entityManager:getEntitiesIn(aabb)
  -- TODO: Sort entities by Y position

  local spriteBatch = self.spriteBatch
  spriteBatch:clear()

  local renderContext = EntityRenderContext(spriteBatch, self.atlasImage)

  for _, entity in ipairs(entities) do
    entity:render(renderContext)
  end

  spriteBatch:flush()
end

function EntityView:draw( ... )
  love.graphics.draw(self.spriteBatch, ...)
end
