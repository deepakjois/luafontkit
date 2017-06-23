local r = require('restructure')
local LookupTable  = require('fontkit.tables.aat').LookupTable

local BslnSubtable = r.VersionedStruct.new('format', {
  [0] = { -- Distance-based, no mapping
    { deltas = r.Array.new(r.int16, 32) },
  },

  [1] = { -- Distance-based, with mapping
    { deltas = r.Array.new(r.int16, 32) },
    { mappingData = LookupTable.new(r.uint16) }
  },

  [2] = { -- Control point-based, no mapping
    { standardGlyph = r.uint16 },
    { controlPoints = r.Array.new(r.uint16, 32) }
  },

  [3] = { -- Control point-based, with mapping
    { standardGlyph = r.uint16 },
    { controlPoints = r.Array.new(r.uint16, 32) },
    { mappingData = LookupTable.new(r.uint16) }
  }
})

return r.Struct.new({
  version = r.fixed32,
  format = r.uint16,
  defaultBaseline = r.uint16,
  subtable = BslnSubtable
})
