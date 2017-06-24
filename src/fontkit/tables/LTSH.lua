local r = require('restructure')

-- Linear Threshold table
-- Records the ppem for each glyph at which the scaling becomes linear again,
-- despite instructions effecting the advance width
return r.Struct.new({
  { version =    r.uint16 },
  { numGlyphs =  r.uint16 },
  { yPels =      r.Array.new(r.uint8, 'numGlyphs') }
})
