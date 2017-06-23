local r = require('restructure')

local BigMetrics = r.Struct.new({
  { height = r.uint8 },
  { width = r.uint8 },
  { horiBearingX = r.int8 },
  { horiBearingY = r.int8 },
  { horiAdvance = r.uint8 },
  { vertBearingX = r.int8 },
  { vertBearingY = r.int8 },
  { vertAdvance = r.uint8 }
})

local SmallMetrics = r.Struct.new({
  { height = r.uint8 },
  { width = r.uint8 },
  { bearingX = r.int8 },
  { bearingY = r.int8 },
  { advance = r.uint8 }
})

local EBDTComponent = r.Struct.new({
  { glyph = r.uint16 },
  { xOffset = r.int8 },
  { yOffset = r.int8 }
})

local ByteAligned = {}
ByteAligned.__index = ByteAligned
function ByteAligned.new()
  return setmetatable({}, ByteAligned)
end

local BitAligned = {}
BitAligned.__index = BitAligned
function BitAligned.new()
  return setmetatable({}, BitAligned)
end


local glyph = r.VersionedStruct.new('version', {
  [1] = {
    { metrics = SmallMetrics },
    { data = ByteAligned }
  },

  [2] = {
    { metrics = SmallMetrics },
    { data = BitAligned }
  },

  -- format 3 is deprecated
  -- format 4 is not supported by Microsoft

  [5] = {
    { data = BitAligned }
  },

  [6] = {
    { metrics = BigMetrics },
    { data = ByteAligned }
  },

  [7] = {
    { metrics = BigMetrics },
    { data = BitAligned }
  },

  [8] = {
    { metrics = SmallMetrics },
    { pad = r.Reserved.new(r.uint8) },
    { numComponents = r.uint16 },
    { components = r.Array.new(EBDTComponent, 'numComponents') }
  },

  [9] = {
    { metrics = BigMetrics },
    { pad = r.Reserved.new(r.uint8) },
    { numComponents = r.uint16 },
    { components = r.Array.new(EBDTComponent, 'numComponents') }
  },

  [17] = {
    { metrics = SmallMetrics },
    { dataLen = r.uint32 },
    { data = r.Buffer.new('dataLen') }
  },

  [18] = {
    { metrics = BigMetrics },
    { dataLen = r.uint32 },
    { data = r.Buffer.new('dataLen') }
  },

  [19] = {
    { dataLen = r.uint32 },
    { data = r.Buffer.new('dataLen') }
  }
})

return {
  BigMetrics = BigMetrics,
  SmallMetrics = SmallMetrics,
  glyph = glyph
}