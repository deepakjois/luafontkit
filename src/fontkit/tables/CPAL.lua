local r = require('restructure')

local ColorRecord = r.Struct.new({
  { blue = r.uint8 },
  { green = r.uint8 },
  { red = r.uint8 },
  { alpha = r.uint8 }
})

return r.VersionedStruct.new(r.uint16, {
  header = {
    { numPaletteEntries = r.uint16 },
    { numPalettes = r.uint16 },
    { numColorRecords = r.uint16 },
    { colorRecords = r.Pointer.new(r.uint32, r.Array.new(ColorRecord, 'numColorRecords')) },
    { colorRecordIndices = r.Array.new(r.uint16, 'numPalettes') }
  },
  [0] = {},
  [1] = {
    { offsetPaletteTypeArray = r.Pointer.new(r.uint32, r.Array.new(r.uint32, 'numPalettes')) },
    { offsetPaletteLabelArray = r.Pointer.new(r.uint32, r.Array.new(r.uint16, 'numPalettes')) },
    { offsetPaletteEntryLabelArray = r.Pointer.new(r.uint32, r.Array.new(r.uint16, 'numPaletteEntries')) }
  }
})
