local r = require('restructure')

local opentype = require('fontkit.tables.opentype')
local ScriptList = opentype.ScriptList
local FeatureList = opentype.FeatureList
local LookupList = opentype.LookupList
local Coverage = opentype.Coverage
local ClassDef = opentype.ClassDef
local Device = opentype.Device
local Context = opentype.Context
local ChainingContext = opentype.ChainingContext

local FeatureVariations = require('fontkit.tables.variations').FeatureVariations

local ValueFormat = r.Bitfield.new(r.uint16, {
  'xPlacement', 'yPlacement',
  'xAdvance', 'yAdvance',
  'xPlaDevice', 'yPlaDevice',
  'xAdvDevice', 'yAdvDevice'
})

local types = {
  xPlacement = r.int16,
  yPlacement = r.int16,
  xAdvance =   r.int16,
  yAdvance =   r.int16,
  xPlaDevice = r.Pointer.new(r.uint16, Device, { type = 'global', relativeTo = 'rel' }),
  yPlaDevice = r.Pointer.new(r.uint16, Device, { type = 'global', relativeTo = 'rel' }),
  xAdvDevice = r.Pointer.new(r.uint16, Device, { type = 'global', relativeTo = 'rel' }),
  yAdvDevice = r.Pointer.new(r.uint16, Device, { type = 'global', relativeTo = 'rel' })
}

local ValueRecord = {}
ValueRecord.__index = ValueRecord

function ValueRecord.new(key)
  if not key then key = 'valueFormat' end
  local v = setmetatable({}, ValueRecord)
  v.key = key
  return v
end

function ValueRecord:buildStruct(parent)
  local struct = parent
  while not struct[self.key] and struct.parent do
    struct = struct.parent
  end

  if not struct[self.key] then return end

  local fields = {}
  table.insert(fields, { rel = function() return struct._startOffset end})

  local format = struct[self.key]
  for key,_ in pairs(format) do
    if format[key] then
      table.insert(fields, { [key] = types[key] })
    end
  end

  return r.Struct.new(fields)
end

function ValueRecord:size(val, ctx)
  return self:buildStruct(ctx):size(val, ctx)
end

function ValueRecord:decode(stream, parent)
  local res = self:buildStruct(parent):decode(stream, parent)
  for i,v in ipairs(res) do
    if v.rel then
      table.remove(res, i)
      break
    end
  end
  return res
end

local PairValueRecord = r.Struct.new({
  secondGlyph =    r.uint16,
  value1 =         ValueRecord.new('valueFormat1'),
  value2 =         ValueRecord.new('valueFormat2')
})

local PairSet = r.Array.new(PairValueRecord, r.uint16)

local Class2Record = r.Struct.new({
  { value1 = ValueRecord.new('valueFormat1') },
  { value2 = ValueRecord.new('valueFormat2') }
})

local Anchor = r.VersionedStruct.new(r.uint16, {
  [1] = { -- Design units only
    { xCoordinate =    r.int16 },
    { yCoordinate =    r.int16 }
  },

  [2] = { -- Design units plus contour point
    { xCoordinate =    r.int16 },
    { yCoordinate =    r.int16 },
    { anchorPoint =    r.uint16 }
  },

  [3] = { -- Design units plus Device tables
    { xCoordinate =    r.int16 },
    { yCoordinate =    r.int16 },
    { xDeviceTable =   r.Pointer.new(r.uint16, Device) },
    { yDeviceTable =   r.Pointer.new(r.uint16, Device) }
  }
})

local EntryExitRecord = r.Struct.new({
  { entryAnchor =    r.Pointer.new(r.uint16, Anchor, {type = 'parent'}) },
  { exitAnchor =     r.Pointer.new(r.uint16, Anchor, {type = 'parent'}) }
})

local MarkRecord = r.Struct.new({
  { class =      r.uint16 },
  { markAnchor = r.Pointer.new(r.uint16, Anchor, {type = 'parent'}) }
})

local MarkArray = r.Array.new(MarkRecord, r.uint16)

local BaseRecord  = r.Array.new(r.Pointer.new(r.uint16, Anchor), function(t) return  t.parent.classCount end)
local BaseArray   = r.Array.new(BaseRecord, r.uint16)

local ComponentRecord = r.Array.new(r.Pointer.new(r.uint16, Anchor), function(t) return  t.parent.parent.classCount end)
local LigatureAttach  = r.Array.new(ComponentRecord, r.uint16)
local LigatureArray   = r.Array.new(r.Pointer.new(r.uint16, LigatureAttach), r.uint16)

local GPOSLookup = nil

GPOSLookup = r.VersionedStruct.new('lookupType', {
  [1] = r.VersionedStruct.new(r.uint16, { -- Single Adjustment
    [1] = { -- Single positioning value
      { coverage =       r.Pointer.new(r.uint16, Coverage) },
      { valueFormat =    ValueFormat },
      { value =          ValueRecord.new() }
    },
    [2] = {
      { coverage =       r.Pointer.new(r.uint16, Coverage) },
      { valueFormat =    ValueFormat },
      { valueCount =     r.uint16 },
      { values =         r.LazyArray.new(ValueRecord.new(), 'valueCount') }
    }
  }),

  [2] = r.VersionedStruct.new(r.uint16, { -- Pair Adjustment Positioning
    [1] = { -- Adjustments for glyph pairs
      { coverage =       r.Pointer.new(r.uint16, Coverage) },
      { valueFormat1 =   ValueFormat },
      { valueFormat2 =   ValueFormat },
      { pairSetCount =   r.uint16 },
      { pairSets =       r.LazyArray.new(r.Pointer.new(r.uint16, PairSet), 'pairSetCount') }
    },

    [2] = { -- Class pair adjustment
      { coverage =       r.Pointer.new(r.uint16, Coverage) },
      { valueFormat1 =   ValueFormat },
      { valueFormat2 =   ValueFormat },
      { classDef1 =      r.Pointer.new(r.uint16, ClassDef) },
      { classDef2 =      r.Pointer.new(r.uint16, ClassDef) },
      { class1Count =    r.uint16 },
      { class2Count =    r.uint16 },
      { classRecords =   r.LazyArray.new(r.LazyArray.new(Class2Record, 'class2Count'), 'class1Count') }
    }
  }),

  [3] = { -- Cursive Attachment Positioning
    { format =             r.uint16 },
    { coverage =           r.Pointer.new(r.uint16, Coverage) },
    { entryExitCount =     r.uint16 },
    { entryExitRecords =   r.Array.new(EntryExitRecord, 'entryExitCount') }
  },

  [4] = { -- MarkToBase Attachment Positioning
    { format =             r.uint16 },
    { markCoverage =       r.Pointer.new(r.uint16, Coverage) },
    { baseCoverage =       r.Pointer.new(r.uint16, Coverage) },
    { classCount =         r.uint16 },
    { markArray =          r.Pointer.new(r.uint16, MarkArray) },
    { baseArray =          r.Pointer.new(r.uint16, BaseArray) }
  },

  [5] = { -- MarkToLigature Attachment Positioning
    { format =             r.uint16 },
    { markCoverage =       r.Pointer.new(r.uint16, Coverage) },
    { ligatureCoverage =   r.Pointer.new(r.uint16, Coverage) },
    { classCount =         r.uint16 },
    { markArray =          r.Pointer.new(r.uint16, MarkArray) },
    { ligatureArray =      r.Pointer.new(r.uint16, LigatureArray) }
  },

  [6] = { -- MarkToMark Attachment Positioning
    { format =             r.uint16 },
    { mark1Coverage =      r.Pointer.new(r.uint16, Coverage) },
    { mark2Coverage =      r.Pointer.new(r.uint16, Coverage) },
    { classCount =         r.uint16 },
    { mark1Array =         r.Pointer.new(r.uint16, MarkArray) },
    { mark2Array =         r.Pointer.new(r.uint16, BaseArray) }
  },

  [7] = Context,          -- Contextual positioning
  [8] = ChainingContext,  -- Chaining contextual positioning

  [9] = { -- Extension Positioning
    { posFormat =   r.uint16 },
    { lookupType =  r.uint16 },   -- cannot also be 9
    { extension =   r.Pointer.new(r.uint32, GPOSLookup) }
  }
})

-- Fix circular reference
GPOSLookup.versions[9].extension.type = GPOSLookup

local GPOS = r.VersionedStruct.new(r.uint32, {
  header = {
    { scriptList =     r.Pointer.new(r.uint16, ScriptList) },
    { featureList =    r.Pointer.new(r.uint16, FeatureList) },
    { lookupList =     r.Pointer.new(r.uint16, LookupList.new(GPOSLookup)) }
  },

  [0x00010000] = {},
  [0x00010001] = {
    { featureVariations = r.Pointer.new(r.uint32, FeatureVariations) }
  }
})

-- GPOSLookup for JSTF table
return {
  GPOSLookup = GPOSLookup,
  GPOS = GPOS
}
