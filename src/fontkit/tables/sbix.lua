local r = require('restructure')

local ImageTable = r.Struct.new({
  { ppem = r.uint16 },
  { resolution = r.uint16 },
  { imageOffsets = r.Array.new(r.Pointer.new(r.uint32, 'void'), function(t) return  t.parent.parent.maxp.numGlyphs + 1 end) }
})

-- This is the Apple sbix table, used by the "Apple Color Emoji" font.
-- It includes several image tables with images for each bitmap glyph
-- of several different sizes.
return r.Struct.new({
  { version = r.uint16 },
  { flags = r.Bitfield.new(r.uint16, {'renderOutlines'}) },
  { numImgTables = r.uint32 },
  { imageTables = r.Array.new(r.Pointer.new(r.uint32, ImageTable), 'numImgTables') }
})
