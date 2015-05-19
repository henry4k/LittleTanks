local imagefont = {}

function imagefont.load()
  return love.graphics.newImageFont('imagefont/font.png',
    ' abcdefghijklmnopqrstuvwxyz' ..
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ0' ..
    '123456789.,!?-+/():;%&`\'*#=[]"')
end

return imagefont
