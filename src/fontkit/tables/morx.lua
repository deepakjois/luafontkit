local r = require('restructure')
local aat = require('fontkit.tables.aat')
local UnboundedArray = aat.UnboundedArray
local LookupTable = aat.LookupTable
local StateTable = aat.StateTable

local LigatureData = {
  action = r.uint16
}

local ContextualData = {
  markIndex = r.uint16,
  currentIndex = r.uint16
}

local InsertionData = {
  currentInsertIndex = r.uint16,
  markedInsertIndex = r.uint16
}

local SubstitutionTable = r.Struct.new({
  { items = UnboundedArray.new(r.Pointer.new(r.uint32, LookupTable.new())) }
})

local SubtableData = r.VersionedStruct.new('type', {
  [0] = { -- Indic Rearrangement Subtable
    { stateTable = StateTable.new() }
  },

  [1] = { -- Contextual Glyph Substitution Subtable
    { stateTable = StateTable.new(ContextualData) },
    { substitutionTable = r.Pointer.new(r.uint32, SubstitutionTable) }
  },

  [2] = { -- Ligature subtable
    { stateTable = StateTable.new(LigatureData) },
    { ligatureActions = r.Pointer.new(r.uint32, UnboundedArray.new(r.uint32)) },
    { components = r.Pointer.new(r.uint32, UnboundedArray.new(r.uint16)) },
    { ligatureList = r.Pointer.new(r.uint32, UnboundedArray.new(r.uint16)) }
  },

  [4] = { -- Non-contextual Glyph Substitution Subtable
    { lookupTable = LookupTable.new() }
  },

  [5] = { -- Glyph Insertion Subtable
    { stateTable = StateTable.new(InsertionData) },
    { insertionActions = r.Pointer.new(r.uint32, UnboundedArray.new(r.uint16)) }
  }
})

local Subtable = r.Struct.new({
  { length = r.uint32 },
  { coverage = r.uint24 },
  { type = r.uint8 },
  { subFeatureFlags = r.uint32 },
  { table = SubtableData },
  { padding = r.Reserved.new(r.uint8, function(t) return  t.length - t._currentOffset end) }
})

local FeatureEntry = r.Struct.new({
  { featureType =    r.uint16 },
  { featureSetting = r.uint16 },
  { enableFlags =    r.uint32 },
  { disableFlags =   r.uint32 }
})

local MorxChain = r.Struct.new({
  { defaultFlags =     r.uint32 },
  { chainLength =      r.uint32 },
  { nFeatureEntries =  r.uint32 },
  { nSubtables =       r.uint32 },
  { features =         r.Array.new(FeatureEntry, 'nFeatureEntries') },
  { subtables =        r.Array.new(Subtable, 'nSubtables') }
})

return r.Struct.new({
  { version =  r.uint16 },
  { unused =   r.Reserved.new(r.uint16) },
  { nChains =  r.uint32 },
  { chains =   r.Array.new(MorxChain, 'nChains') }
})
