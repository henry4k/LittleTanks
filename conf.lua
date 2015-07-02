function love.conf( t )
  t.version = '0.9.2'
  t.identity = 'LittleTanks'

  t.window.title = 'Little Tanks'
  t.window.resizable = true
  t.window.highdpi = true

  t.window.display = 2
  t.window.width = 800
  t.window.height = 600

  t.modules.joystick = false
  t.modules.physics = false
  t.modules.thread = false
end
