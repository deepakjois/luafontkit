local r = require('restructure')

--########################
-- Scripts and Languages #
--########################

local LangSysTable = r.Struct.new({
  { reserved =         r.Reserved.new(r.uint16) },
  { reqFeatureIndex =  r.uint16 },
  { featureCount =     r.uint16 },
  { featureIndexes =   r.Array.new(r.uint16, 'featureCount') }
})

local LangSysRecord = r.Struct.new({
  { tag =      r.String.new(4) },
  { langSys =  r.Pointer.new(r.uint16, LangSysTable, { type = 'parent' }) }
})

local Script = r.Struct.new({
  { defaultLangSys = r.Pointer.new(r.uint16, LangSysTable) },
  { count =          r.uint16 },
  { langSysRecords = r.Array.new(LangSysRecord, 'count') }
})

local ScriptRecord = r.Struct.new({
  { tag =    r.String.new(4) },
  { script = r.Pointer.new(r.uint16, Script, { type = 'parent' }) }
})

local ScriptList = r.Array.new(ScriptRecord, r.uint16)

--#######################
-- Features and Lookups #
--#######################

local Feature = r.Struct.new({
  { featureParams =      r.uint16 }, -- pointer
  { lookupCount =        r.uint16 },
  { lookupListIndexes =  r.Array.new(r.uint16, 'lookupCount') }
})

local FeatureRecord = r.Struct.new({
  { tag =      r.String.new(4) },
  { feature =  r.Pointer.new(r.uint16, Feature, { type = 'parent' }) }
})

local FeatureList = r.Array.new(FeatureRecord, r.uint16)

local LookupFlags = r.Struct.new({
  { markAttachmentType = r.uint8 },
  { flags = r.Bitfield.new(r.uint8, {
    'rightToLeft', 'ignoreBaseGlyphs', 'ignoreLigatures',
    'ignoreMarks', 'useMarkFilteringSet'
  }) }
})

local function LookupList(SubTable)
  local Lookup = r.Struct.new({
    { lookupType =         r.uint16 },
    { flags =              LookupFlags },
    { subTableCount =      r.uint16 },
    { subTables =          r.Array.new(r.Pointer.new(r.uint16, SubTable), 'subTableCount') },
    { markFilteringSet =   r.Optional.new(r.uint16, function(t) return  t.flags.flags.useMarkFilteringSet end) }
  })

  return r.LazyArray.new(r.Pointer.new(r.uint16, Lookup), r.uint16)
end

--#################
-- Coverage Table #
--#################

local RangeRecord = r.Struct.new({
  { start =              r.uint16 },
  { ["end"] =                r.uint16 },
  { startCoverageIndex = r.uint16 }
})

local Coverage = r.VersionedStruct.new(r.uint16, {
  [1] = {
    { glyphCount =   r.uint16 },
    { glyphs =       r.Array.new(r.uint16, 'glyphCount') }
  },
  [2] = {
    { rangeCount =   r.uint16 },
    { rangeRecords = r.Array.new(RangeRecord, 'rangeCount') }
  }
})

--#########################
-- Class Definition Table #
--#########################

local ClassRangeRecord = r.Struct.new({
  { start =  r.uint16 },
  { ["end"] =    r.uint16 },
  { class =  r.uint16 }
})

local ClassDef = r.VersionedStruct.new(r.uint16, {
  [1] = { -- Class array
    { startGlyph =       r.uint16 },
    { glyphCount =       r.uint16 },
    { classValueArray =  r.Array.new(r.uint16, 'glyphCount') }
  },
  [2] = { -- Class ranges
    { classRangeCount =  r.uint16 },
    { classRangeRecord = r.Array.new(ClassRangeRecord, 'classRangeCount') }
  }
})

--###############
-- Device Table #
--###############

local Device = r.Struct.new({
  { a = r.uint16 }, -- startSize for hinting Device, outerIndex for VariationIndex
  { b = r.uint16 }, -- endSize for Device, innerIndex for VariationIndex
  { deltaFormat = r.uint16 }
})

--#############################################
-- Contextual Substitution/Positioning Tables #
--#############################################

local LookupRecord = r.Struct.new({
  { sequenceIndex =      r.uint16 },
  { lookupListIndex =    r.uint16 }
})

local Rule = r.Struct.new({
  { glyphCount =     r.uint16 },
  { lookupCount =    r.uint16 },
  { input =          r.Array.new(r.uint16, function(t) return  t.glyphCount - 1 end) },
  { lookupRecords =  r.Array.new(LookupRecord, 'lookupCount') }
})

local RuleSet = r.Array.new(r.Pointer.new(r.uint16, Rule), r.uint16)

local ClassRule = r.Struct.new({
  { glyphCount =     r.uint16 },
  { lookupCount =    r.uint16 },
  { classes =        r.Array.new(r.uint16, function(t) return  t.glyphCount - 1 end) },
  { lookupRecords =  r.Array.new(LookupRecord, 'lookupCount') }
})

local ClassSet = r.Array.new(r.Pointer.new(r.uint16, ClassRule), r.uint16)

local Context = r.VersionedStruct.new(r.uint16, {
  [1] = { -- Simple context
    { coverage =      r.Pointer.new(r.uint16, Coverage) },
    { ruleSetCount =  r.uint16 },
    { ruleSets =      r.Array.new(r.Pointer.new(r.uint16, RuleSet), 'ruleSetCount') }
  },
  [2] = { -- Class-based context
    { coverage =      r.Pointer.new(r.uint16, Coverage) },
    { classDef =      r.Pointer.new(r.uint16, ClassDef) },
    { classSetCnt =   r.uint16 },
    { classSet =      r.Array.new(r.Pointer.new(r.uint16, ClassSet), 'classSetCnt') }
  },
  [3] = {
    { glyphCount =    r.uint16 },
    { lookupCount =   r.uint16 },
    { coverages =     r.Array.new(r.Pointer.new(r.uint16, Coverage), 'glyphCount') },
    { lookupRecords = r.Array.new(LookupRecord, 'lookupCount') }
  }
})

--######################################################
-- Chaining Contextual Substitution/Positioning Tables #
--######################################################

local ChainRule = r.Struct.new({
  { backtrackGlyphCount =  r.uint16 },
  { backtrack =            r.Array.new(r.uint16, 'backtrackGlyphCount') },
  { inputGlyphCount =      r.uint16 },
  { input =                r.Array.new(r.uint16, function(t) return  t.inputGlyphCount - 1 end) },
  { lookaheadGlyphCount =  r.uint16 },
  { lookahead =            r.Array.new(r.uint16, 'lookaheadGlyphCount') },
  { lookupCount =          r.uint16 },
  { lookupRecords =        r.Array.new(LookupRecord, 'lookupCount') }
})

local ChainRuleSet = r.Array.new(r.Pointer.new(r.uint16, ChainRule), r.uint16)

local ChainingContext = r.VersionedStruct.new(r.uint16, {
  [1] = { -- Simple context glyph substitution
    { coverage =           r.Pointer.new(r.uint16, Coverage) },
    { chainCount =         r.uint16 },
    { chainRuleSets =      r.Array.new(r.Pointer.new(r.uint16, ChainRuleSet), 'chainCount') }
  },

  [2] = { -- Class-based chaining context
    { coverage =           r.Pointer.new(r.uint16, Coverage) },
    { backtrackClassDef =  r.Pointer.new(r.uint16, ClassDef) },
    { inputClassDef =      r.Pointer.new(r.uint16, ClassDef) },
    { lookaheadClassDef =  r.Pointer.new(r.uint16, ClassDef) },
    { chainCount =         r.uint16 },
    { chainClassSet =      r.Array.new(r.Pointer.new(r.uint16, ChainRuleSet), 'chainCount') }
  },

  [3] = { -- Coverage-based chaining context
    { backtrackGlyphCount =    r.uint16 },
    { backtrackCoverage =      r.Array.new(r.Pointer.new(r.uint16, Coverage), 'backtrackGlyphCount') },
    { inputGlyphCount =        r.uint16 },
    { inputCoverage =          r.Array.new(r.Pointer.new(r.uint16, Coverage), 'inputGlyphCount') },
    { lookaheadGlyphCount =    r.uint16 },
    { lookaheadCoverage =      r.Array.new(r.Pointer.new(r.uint16, Coverage), 'lookaheadGlyphCount') },
    { lookupCount =            r.uint16 },
    { lookupRecords =          r.Array.new(LookupRecord, 'lookupCount') }
  }
})

return {
  ScriptList = ScriptList,
  Feature = Feature,
  FeatureList = FeatureList,
  LookupList = LookupList,
  Coverage = Coverage,
  ClassDef = ClassDef,
  Device = Device,
  Context = Context,
  ChainingContext = ChainingContext
}