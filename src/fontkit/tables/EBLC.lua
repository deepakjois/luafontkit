local r = require('restructure')
local BigMetrics = require('fontkit.tables.EBDT').BigMetrics

local SBitLineMetrics = r.Struct.new({
  { ascender = r.int8 },
  { descender = r.int8 },
  { widthMax = r.uint8 },
  { caretSlopeNumerator = r.int8 },
  { caretSlopeDenominator = r.int8 },
  { caretOffset = r.int8 },
  { minOriginSB = r.int8 },
  { minAdvanceSB = r.int8 },
  { maxBeforeBL = r.int8 },
  { minAfterBL = r.int8 },
  { pad = r.Reserved.new(r.int8, 2) }
})

local CodeOffsetPair = r.Struct.new({
  { glyphCode = r.uint16 },
  { offset = r.uint16 }
})

local IndexSubtable = r.VersionedStruct.new(r.uint16, {
  header = {
    { imageFormat = r.uint16 },
    { imageDataOffset = r.uint32 }
  },

  [1] = {
    { offsetArray = r.Array.new(r.uint32, function(t) return t.parent.lastGlyphIndex - t.parent.firstGlyphIndex + 1 end) }
  },

  [2] = {
    { imageSize = r.uint32 },
    { bigMetrics = BigMetrics }
  },

  [3] = {
    { offsetArray = r.Array.new(r.uint16, function(t) return t.parent.lastGlyphIndex - t.parent.firstGlyphIndex + 1 end) }
  },

  [4] = {
    { numGlyphs = r.uint32 },
    { glyphArray = r.Array.new(CodeOffsetPair, function(t) return t.numGlyphs + 1 end) }
  },

  [5] = {
    { imageSize = r.uint32 },
    { bigMetrics = BigMetrics },
    { numGlyphs = r.uint32 },
    { glyphCodeArray = r.Array.new(r.uint16, 'numGlyphs') }
  }
})

local IndexSubtableArray = r.Struct.new({
  { firstGlyphIndex = r.uint16 },
  { lastGlyphIndex = r.uint16 },
  { subtable = r.Pointer.new(r.uint32, IndexSubtable) }
})

local BitmapSizeTable = r.Struct.new({
  { indexSubTableArray = r.Pointer.new(r.uint32, r.Array.new(IndexSubtableArray, 1), { type = 'parent' }) },
  { indexTablesSize = r.uint32 },
  { numberOfIndexSubTables = r.uint32 },
  { colorRef = r.uint32 },
  { hori = SBitLineMetrics },
  { vert = SBitLineMetrics },
  { startGlyphIndex = r.uint16 },
  { endGlyphIndex = r.uint16 },
  { ppemX = r.uint8 },
  { ppemY = r.uint8 },
  { bitDepth = r.uint8 },
  { flags = r.Bitfield.new(r.uint8, {'horizontal', 'vertical'}) }
})

return r.Struct.new({
  { version =  r.uint32 }, -- 0x00020000
  { numSizes = r.uint32 },
  { sizes =    r.Array.new(BitmapSizeTable, 'numSizes') }
})
