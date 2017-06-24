local r = require('restructure')

local DeviceRecord = r.Struct.new({
  { pixelSize =      r.uint8 },
  { maximumWidth =   r.uint8 },
  { widths =         r.Array.new(r.uint8, function(t) return  t.parent.parent.maxp.numGlyphs end) }
})

-- The Horizontal Device Metrics table stores integer advance widths scaled to particular pixel sizes
return r.Struct.new({
  { version =            r.uint16 },
  { numRecords =         r.int16 },
  { sizeDeviceRecord =   r.int32 },
  { records =            r.Array.new(DeviceRecord, 'numRecords') }
})
