local r = require('restructure')
local opentype = require('fontkit.tables.opentype')
local variations = require('fontkit.tables.variations')

local Device = opentype.Device

local ItemVariationStore = variations.ItemVariationStore

local BaseCoord =  r.VersionedStruct.new(r.uint16, {
  [1] = { -- Design units only
    { coordinate =   r.int16 } -- X or Y value, in design units
  },

  [2] = { -- Design units plus contour point
    { coordinate =     r.int16 },   -- X or Y value, in design units
    { referenceGlyph = r.uint16 },  -- GlyphID of control glyph
    { baseCoordPoint = r.uint16 }   -- Index of contour point on the referenceGlyph
  },

  [3] = { -- Design units plus Device table
    { coordinate =   r.int16 },                         -- X or Y value, in design units
    { deviceTable =   r.Pointer.new(r.uint16, Device) }  -- Device table for X or Y value
  }
})

local BaseValues =  r.Struct.new({
  { defaultIndex =   r.uint16 },  -- Index of default baseline for this script-same index in the BaseTagList
  { baseCoordCount = r.uint16 },
  { baseCoords =  r.Array.new(r.Pointer.new(r.uint16, BaseCoord), 'baseCoordCount') }
})

local FeatMinMaxRecord = r.Struct.new({
  { tag =         r.String.new(4) },  -- 4-byte feature identification tag-must match FeatureTag in FeatureList
  { minCoord =    r.Pointer.new(r.uint16, BaseCoord, {type = 'parent'}) }, -- May be NULL
  { maxCoord =    r.Pointer.new(r.uint16, BaseCoord, {type = 'parent'}) }  -- May be NULL
})

local MinMax = r.Struct.new({
  { minCoord =            r.Pointer.new(r.uint16, BaseCoord) },  -- May be NULL
  { maxCoord =            r.Pointer.new(r.uint16, BaseCoord) },  -- May be NULL
  { featMinMaxCount =    r.uint16 },                            -- May be 0
  { featMinMaxRecords =   r.Array.new(FeatMinMaxRecord, 'featMinMaxCount') } -- In alphabetical order
})

local BaseLangSysRecord =  r.Struct.new({
  { tag =     r.String.new(4) },  -- 4-byte language system identification tag
  { minMax =  r.Pointer.new(r.uint16, MinMax, {type = 'parent'}) }
})

local BaseScript =  r.Struct.new({
  { baseValues =          r.Pointer.new(r.uint16, BaseValues) }, -- May be NULL
  { defaultMinMax =       r.Pointer.new(r.uint16, MinMax) },     -- May be NULL
  { baseLangSysCount =   r.uint16 },                            -- May be 0
  { baseLangSysRecords =  r.Array.new(BaseLangSysRecord, 'baseLangSysCount') } -- in alphabetical order by BaseLangSysTag
})

local BaseScriptRecord =  r.Struct.new({
  { tag =       r.String.new(4) },  -- 4-byte script identification tag
  { script =    r.Pointer.new(r.uint16, BaseScript, {type = 'parent'}) }
})

local BaseScriptList =  r.Array.new(BaseScriptRecord, r.uint16)

-- Array of 4-byte baseline identification tags-must be in alphabetical order
local BaseTagList =  r.Array.new(r.String.new(4), r.uint16)

local Axis =  r.Struct.new({
  { baseTagList =     r.Pointer.new(r.uint16, BaseTagList) },  -- May be NULL
  { baseScriptList =  r.Pointer.new(r.uint16, BaseScriptList) }
})

return r.VersionedStruct.new(r.uint32, {
  header = {
    { horizAxis =     r.Pointer.new(r.uint16, Axis) },   -- May be NULL
    { vertAxis =      r.Pointer.new(r.uint16, Axis) }    -- May be NULL
  },

  [0x00010000] = {},
  [0x00010001] = {
    { itemVariationStore =  r.Pointer.new(r.uint32, ItemVariationStore) }
  }
})
