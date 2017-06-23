local r = require('restructure')

local ColorRecord = r.Struct.new({
  { blue = r.uint8 },
  { green = r.uint8 },
  { red = r.uint8 },
  { alpha = r.uint8 }
})

return r.Struct.new({
  { version = r.uint16 },
  { numPaletteEntries = r.uint16 },
  { numPalettes = r.uint16 },
  { numColorRecords = r.uint16 },
  { colorRecords = r.Pointer.new(r.uint32, r.Array.new(ColorRecord, 'numColorRecords')) },
  { colorRecordIndices = r.Array.new(r.uint16, 'numPalettes') }
})
