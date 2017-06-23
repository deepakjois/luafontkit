local r = require('restructure')

local Axis = r.Struct.new({
  { axisTag = r.String.new(4) },
  { minValue = r.fixed32 },
  { defaultValue = r.fixed32 },
  { maxValue = r.fixed32 },
  { flags = r.uint16 },
  { nameID = r.uint16 },
  { name = function(t) return  t.parent.parent.name.records.fontFeatures[t.nameID] end }
})

local Instance = r.Struct.new({
  { nameID = r.uint16 },
  { name = function(t) return  t.parent.parent.name.records.fontFeatures[t.nameID] end },
  { flags = r.uint16 },
  { coord = r.Array.new(r.fixed32, function(t) return  t.parent.axisCount end) },
  { postscriptNameID = r.Optional.new(r.uint16, function(t) return  t.parent.instanceSize - t._currentOffset > 0 end) }
})

return r.Struct.new({
  { version = r.fixed32 },
  { offsetToData = r.uint16 },
  { countSizePairs = r.uint16 },
  { axisCount = r.uint16 },
  { axisSize = r.uint16 },
  { instanceCount = r.uint16 },
  { instanceSize = r.uint16 },
  { axis = r.Array.new(Axis, 'axisCount') },
  { instance = r.Array.new(Instance, 'instanceCount') }
})
