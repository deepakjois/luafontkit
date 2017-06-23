local r = require('restructure')

local Setting = r.Struct.new({
  { setting = r.uint16 },
  { nameIndex = r.int16 },
  { name = function(t) return  t.parent.parent.parent.name.records.fontFeatures[t.nameIndex] end }
})

local FeatureName = r.Struct.new({
  { feature = r.uint16 },
  { nSettings = r.uint16 },
  { settingTable = r.Pointer.new(r.uint32, r.Array.new(Setting, 'nSettings'), { type = 'parent' }) },
  { featureFlags = r.Bitfield.new(r.uint8, {
    nil, nil, nil, nil, nil, nil,
    'hasDefault', 'exclusive'
  }) },
  { defaultSetting = r.uint8 },
  { nameIndex = r.int16 },
  { name = function(t) return  t.parent.parent.name.records.fontFeatures[t.nameIndex] end }
})

return r.Struct.new({
  { version = r.fixed32 },
  { featureNameCount = r.uint16 },
  { reserved1 = r.Reserved.new(r.uint16) },
  { reserved2 = r.Reserved.new(r.uint32) },
  { featureNames = r.Array.new(FeatureName, 'featureNameCount') }
})
