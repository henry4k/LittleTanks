function love.conf( t )
  t.version = '0.9.2'
  t.identity = 'LoveTest'

  t.window.title = 'LoveTest'
  t.window.resizable = true
  t.window.highdpi = true

  t.modules.joystick = false
  t.modules.physics = false
  t.modules.thread = false
end
