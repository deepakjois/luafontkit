local r = require('restructure')
local opentype = require('fontkit.tables.opentype')
local ScriptList = opentype.ScriptList
local FeatureList = opentype.FeatureList
local LookupList = opentype.LookupList
local Coverage = opentype.Coverage
local Context = opentype.Context
local ChainingContext = opentype.ChainingContext

local FeatureVariations = require('fontkit.tables.variations').FeatureVariations

local Sequence = r.Array.new(r.uint16, r.uint16)
local AlternateSet = Sequence

local Ligature = r.Struct.new({
  { glyph =      r.uint16 },
  { compCount =  r.uint16 },
  { components = r.Array.new(r.uint16, function(t) return  t.compCount - 1 end) }
})

local LigatureSet = r.Array.new(r.Pointer.new(r.uint16, Ligature), r.uint16)

local GSUBLookup = nil
GSUBLookup = r.VersionedStruct.new('lookupType', {
  [1] = r.VersionedStruct.new(r.uint16, {-- Single Substitution
    [1] = {
      { coverage =       r.Pointer.new(r.uint16, Coverage) },
      { deltaGlyphID =   r.int16 }
    },
    [2] = {
      { coverage =       r.Pointer.new(r.uint16, Coverage) },
      { glyphCount =     r.uint16 },
      { substitute =     r.LazyArray.new(r.uint16, 'glyphCount') }
    }
  }),

  [2] = { -- Multiple Substitution
    { substFormat =    r.uint16 },
    { coverage =       r.Pointer.new(r.uint16, Coverage) },
    { count =          r.uint16 },
    { sequences =      r.LazyArray.new(r.Pointer.new(r.uint16, Sequence), 'count') }
  },

  [3] = { -- Alternate Substitution
    { substFormat =    r.uint16 },
    { coverage =       r.Pointer.new(r.uint16, Coverage) },
    { count =          r.uint16 },
    { alternateSet =   r.LazyArray.new(r.Pointer.new(r.uint16, AlternateSet), 'count') }
  },

  [4] = { -- Ligature Substitution
    { substFormat =    r.uint16 },
    { coverage =       r.Pointer.new(r.uint16, Coverage) },
    { count =          r.uint16 },
    { ligatureSets =   r.LazyArray.new(r.Pointer.new(r.uint16, LigatureSet), 'count') }
  },

  [5] = Context,         -- Contextual Substitution
  [6] = ChainingContext, -- Chaining Contextual Substitution

  [7] = { -- Extension Substitution
    { substFormat =   r.uint16 },
    { lookupType =    r.uint16 },   -- cannot also be 7
    { extension =     r.Pointer.new(r.uint32, GSUBLookup) }
  },

  [8] = { -- Reverse Chaining Contextual Single Substitution
    { substFormat =            r.uint16 },
    { coverage =               r.Pointer.new(r.uint16, Coverage) },
    { backtrackCoverage =      r.Array.new(r.Pointer.new(r.uint16, Coverage), 'backtrackGlyphCount') },
    { lookaheadGlyphCount =    r.uint16 },
    { lookaheadCoverage =      r.Array.new(r.Pointer.new(r.uint16, Coverage), 'lookaheadGlyphCount') },
    { glyphCount =             r.uint16 },
    { substitutes =            r.Array.new(r.uint16, 'glyphCount') }
  }
})

-- Fix circular reference
GSUBLookup.versions[7].extension.type = GSUBLookup

return r.VersionedStruct.new(r.uint32, {
  header = {
    { scriptList =     r.Pointer.new(r.uint16, ScriptList) },
    { featureList =    r.Pointer.new(r.uint16, FeatureList) },
    { lookupList =     r.Pointer.new(r.uint16, LookupList.new(GSUBLookup)) }
  },

  [0x00010000] = {},
  [0x00010001] = {
    { featureVariations = r.Pointer.new(r.uint32, FeatureVariations) }
  }
})
