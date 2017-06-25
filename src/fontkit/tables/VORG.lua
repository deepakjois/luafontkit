local r = require('restructure')

local VerticalOrigin = r.Struct.new({
  { glyphIndex =   r.uint16 },
  { vertOriginY =  r.int16 }
})

return r.Struct.new({
  { majorVersion =           r.uint16 },
  { minorVersion =           r.uint16 },
  { defaultVertOriginY =     r.int16 },
  { numVertOriginYMetrics =  r.uint16 },
  { metrics =                r.Array.new(VerticalOrigin, 'numVertOriginYMetrics') }
})
