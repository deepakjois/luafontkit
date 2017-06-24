local r = require('restructure')

-- font header
return r.Struct.new({
  { version =            r.int32 },                   -- 0x00010000 (version 1.0)
  { revision =           r.int32 },                   -- set by font manufacturer
  { checkSumAdjustment = r.uint32 },
  { magicNumber =        r.uint32 },                  -- set to 0x5F0F3CF5
  { flags =              r.uint16 },
  { unitsPerEm =         r.uint16 },                  -- range from 64 to 16384
  { created =            r.Array.new(r.int32, 2) },
  { modified =           r.Array.new(r.int32, 2) },
  { xMin =               r.int16 },                   -- for all glyph bounding boxes
  { yMin =               r.int16 },                   -- for all glyph bounding boxes
  { xMax =               r.int16 },                   -- for all glyph bounding boxes
  { yMax =               r.int16 },                   -- for all glyph bounding boxes
  { macStyle =           r.Bitfield.new(r.uint16, {
    'bold', 'italic', 'underline', 'outline',
    'shadow', 'condensed', 'extended'
  }) },
  { lowestRecPPEM =      r.uint16 },                  -- smallest readable size in pixels
  { fontDirectionHint =  r.int16 },
  { indexToLocFormat =   r.int16 },                   -- 0 for short offsets, 1 for long
  { glyphDataFormat =    r.int16 }                    -- 0 for current format
})
