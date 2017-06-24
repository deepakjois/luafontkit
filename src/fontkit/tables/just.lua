local r = require('restructure')
local aat =  require('fontkit.tables.aat')
local LookupTable = aat.LookupTable
local StateTable1 = aat.StateTable1

local ClassTable = r.Struct.new({
  { length = r.uint16 },
  { coverage = r.uint16 },
  { subFeatureFlags = r.uint32 },
  { stateTable = StateTable1.new() }
})

local WidthDeltaRecord = r.Struct.new({
  { justClass = r.uint32 },
  { beforeGrowLimit = r.fixed32 },
  { beforeShrinkLimit = r.fixed32 },
  { afterGrowLimit = r.fixed32 },
  { afterShrinkLimit = r.fixed32 },
  { growFlags = r.uint16 },
  { shrinkFlags = r.uint16 }
})

local WidthDeltaCluster = r.Array.new(WidthDeltaRecord, r.uint32)

local ActionData = r.VersionedStruct.new('actionType', {
  [0] = { -- Decomposition action
    { lowerLimit = r.fixed32 },
    { upperLimit = r.fixed32 },
    { order = r.uint16 },
    { glyphs = r.Array.new(r.uint16, r.uint16) }
  },

  [1] = { -- Unconditional add glyph action
    { addGlyph = r.uint16 }
  },

  [2] = { -- Conditional add glyph action
    { substThreshold = r.fixed32 },
    { addGlyph = r.uint16 },
    { substGlyph = r.uint16 }
  },

  [3] = {}, -- Stretch glyph action (no data, not supported by CoreText)

  [4] = { -- Ductile glyph action (not supported by CoreText)
    { variationAxis = r.uint32 },
    { minimumLimit = r.fixed32 },
    { noStretchValue = r.fixed32 },
    { maximumLimit = r.fixed32 }
  },

  [5] = { -- Repeated add glyph action
    { flags = r.uint16 },
    { glyph = r.uint16 }
  }
})

local Action = r.Struct.new({
  { actionClass = r.uint16 },
  { actionType = r.uint16 },
  { actionLength = r.uint32 },
  { actionData = ActionData },
  { padding = r.Reserved.new(r.uint8, function(t) return  t.actionLength - t._currentOffset end) }
})

local PostcompensationAction = r.Array.new(Action, r.uint32)
local PostCompensationTable = r.Struct.new({
  { lookupTable = LookupTable.new(r.Pointer.new(r.uint16, PostcompensationAction)) }
})

local JustificationTable = r.Struct.new({
  { classTable = r.Pointer.new(r.uint16, ClassTable, { type = 'parent' }) },
  { wdcOffset = r.uint16 },
  { postCompensationTable = r.Pointer.new(r.uint16, PostCompensationTable, { type = 'parent' }) },
  { widthDeltaClusters = LookupTable.new(r.Pointer.new(r.uint16, WidthDeltaCluster, { type = 'parent', relativeTo = 'wdcOffset' })) }
})

return r.Struct.new({
  { version = r.uint32 },
  { format = r.uint16 },
  { horizontal = r.Pointer.new(r.uint16, JustificationTable) },
  { vertical = r.Pointer.new(r.uint16, JustificationTable) }
})
