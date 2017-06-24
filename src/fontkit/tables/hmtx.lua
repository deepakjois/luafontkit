local r = require('restructure')

local HmtxEntry = r.Struct.new({
  { advance = r.uint16 },
  { bearing = r.int16 }
})

return r.Struct.new({
  { metrics =    r.LazyArray.new(HmtxEntry, function(t) return  t.parent.hhea.numberOfMetrics end) },
  { bearings =   r.LazyArray.new(r.int16, function(t) return  t.parent.maxp.numGlyphs - t.parent.hhea.numberOfMetrics end) }
})
