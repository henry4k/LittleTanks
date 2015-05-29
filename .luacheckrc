-- vim: set filetype=lua:
std = 'lua51'
unused_args = false
--allow_defined_top = true
globals = { 'love' }
-- Third party:
files['bump.lua'] = {
  ignore = {'431', '311', '432'}
}
files['gamera.lua'] = {
  ignore = {'211'}
}
files['main.lua'] = {
  ignore = {'111', '112', '113'}
}
