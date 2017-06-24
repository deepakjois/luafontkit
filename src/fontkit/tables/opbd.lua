local r = require('restructure')
local LookupTable = require('fontkit.tables.aat').LookupTable

local OpticalBounds = r.Struct.new({
  { left = r.int16 },
  { top = r.int16 },
  { right = r.int16 },
  { bottom = r.int16 }
})

return r.Struct.new({
  { version = r.fixed32 },
  { format = r.uint16 },
  { lookupTable = LookupTable.new(OpticalBounds) }
})
