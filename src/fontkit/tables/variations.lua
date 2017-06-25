local Feature = require('fontkit.tables.opentype').Feature
local r = require('restructure')

-- *******************
-- Variation Store *
-- *******************

local F2DOT14 = r.Fixed.new(16, 'BE', 14)
local RegionAxisCoordinates = r.Struct.new({
  { startCoord = F2DOT14 },
  { peakCoord = F2DOT14 },
  { endCoord = F2DOT14 }
})

local VariationRegionList = r.Struct.new({
  { axisCount = r.uint16 },
  { regionCount = r.uint16 },
  { variationRegions = r.Array.new(r.Array.new(RegionAxisCoordinates, 'axisCount'), 'regionCount') }
})

local DeltaSet = r.Struct.new({
  { shortDeltas = r.Array.new(r.int16, function(t) return  t.parent.shortDeltaCount end) },
  { regionDeltas = r.Array.new(r.int8, function(t) return  t.parent.regionIndexCount - t.parent.shortDeltaCount end) },
  { deltas = function(t) return  t.shortDeltas.concat(t.regionDeltas) end }
})

local ItemVariationData = r.Struct.new({
  { itemCount = r.uint16 },
  { shortDeltaCount = r.uint16 },
  { regionIndexCount = r.uint16 },
  { regionIndexes = r.Array.new(r.uint16, 'regionIndexCount') },
  { deltaSets = r.Array.new(DeltaSet, 'itemCount') }
})

local ItemVariationStore = r.Struct.new({
  { format = r.uint16 },
  { variationRegionList = r.Pointer.new(r.uint32, VariationRegionList) },
  { variationDataCount = r.uint16 },
  { itemVariationData = r.Array.new(r.Pointer.new(r.uint32, ItemVariationData), 'variationDataCount') }
})

-- **********************
-- * Feature Variations *
-- **********************

local ConditionTable = r.VersionedStruct.new(r.uint16, {
  [1] = {
    { axisIndex = r.uint16 },
    { axisIndex = r.uint16 },
    { filterRangeMinValue = F2DOT14 },
    { filterRangeMaxValue = F2DOT14 }
  }
})

local ConditionSet = r.Struct.new({
  { conditionCount = r.uint16 },
  { conditionTable = r.Array.new(r.Pointer.new(r.uint32, ConditionTable), 'conditionCount') }
})

local FeatureTableSubstitutionRecord = r.Struct.new({
  { featureIndex = r.uint16 },
  { alternateFeatureTable = r.Pointer.new(r.uint32, Feature, {type = 'parent'}) }
})

local FeatureTableSubstitution = r.Struct.new({
  { version = r.fixed32 },
  { substitutionCount = r.uint16 },
  { substitutions = r.Array.new(FeatureTableSubstitutionRecord, 'substitutionCount') }
})

local FeatureVariationRecord = r.Struct.new({
  { conditionSet = r.Pointer.new(r.uint32, ConditionSet, {type = 'parent'}) },
  { featureTableSubstitution = r.Pointer.new(r.uint32, FeatureTableSubstitution, {type = 'parent'}) }
})

local FeatureVariations = r.Struct.new({
  { majorVersion = r.uint16 },
  { minorVersion = r.uint16 },
  { featureVariationRecordCount = r.uint32 },
  { featureVariationRecords = r.Array.new(FeatureVariationRecord, 'featureVariationRecordCount') }
})

return {
  ItemVariationStore = ItemVariationStore,
  FeatureVariations = FeatureVariations
}
