local r = require('restructure')

local shortFrac = r.Fixed.new(16, 'BE', 14)

local Offset = {}
Offset.__index = Offset
function Offset.new()
  return setmetatable({}, Offset)
end

function Offset.decode(stream, parent)
  -- In short format, offsets are multiplied by 2.
  -- This doesn't seem to be documented by Apple, but it
  -- is implemented this way in Freetype.
  if parent.flags then return stream.readUInt32BE() else return stream.readUInt16BE() * 2 end
end

local gvar = r.Struct.new({
  { version = r.uint16 },
  { reserved = r.Reserved.new(r.uint16) },
  { axisCount = r.uint16 },
  { globalCoordCount = r.uint16 },
  { globalCoords = r.Pointer.new(r.uint32, r.Array.new(r.Array.new(shortFrac, 'axisCount'), 'globalCoordCount')) },
  { glyphCount = r.uint16 },
  { flags = r.uint16 },
  { offsetToData = r.uint32 },
  { offsets = r.Array.new(r.Pointer.new(Offset, 'void', { relativeTo = 'offsetToData', allowNull = false }), function(t) return  t.glyphCount + 1 end) }
})

return gvar
