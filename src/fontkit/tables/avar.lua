local r = require('restructure')

local shortFrac = r.Fixed.new(16, 'BE', 14)

local Correspondence = r.Struct.new({
  { fromCoord = shortFrac },
  { toCoord = shortFrac }
})

local Segment = r.Struct.new({
  { pairCount = r.uint16 },
  { correspondence = r.Array.new(Correspondence, 'pairCount') }
})

return r.Struct.new({
  version = r.fixed32,
  axisCount = r.uint32,
  segment = r.Array.new(Segment, 'axisCount')
})
