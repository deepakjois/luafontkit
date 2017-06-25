local r = require('restructure')

local VmtxEntry = r.Struct.new({
  { advance = r.uint16 },  -- The advance height of the glyph
  { bearing = r.int16 }    -- The top sidebearing of the glyph
})

-- Vertical Metrics Table
return r.Struct.new({
  { metrics =  r.LazyArray.new(VmtxEntry, function(t) return  t.parent.vhea.numberOfMetrics end) },
  { bearings = r.LazyArray.new(r.int16, function(t) return  t.parent.maxp.numGlyphs - t.parent.vhea.numberOfMetrics end) }
})
