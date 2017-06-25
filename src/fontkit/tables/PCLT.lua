local r = require('restructure')

-- PCL 5 Table
-- NOTE = The PCLT table is strongly discouraged for OpenType fonts with TrueType outlines
return r.Struct.new({
  { version =              r.uint16 },
  { fontNumber =           r.uint32 },
  { pitch =                r.uint16 },
  { xHeight =              r.uint16 },
  { style =                r.uint16 },
  { typeFamily =           r.uint16 },
  { capHeight =            r.uint16 },
  { symbolSet =            r.uint16 },
  { typeface =             r.String.new(16) },
  { characterComplement =  r.String.new(8) },
  { fileName =             r.String.new(6) },
  { strokeWeight =         r.String.new(1) },
  { widthType =            r.String.new(1) },
  { serifStyle =           r.uint8 },
  { reserved =             r.Reserved.new(r.uint8) }
})
