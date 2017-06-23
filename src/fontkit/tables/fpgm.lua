local r = require('restructure')

-- A list of instructions that are executed once when a font is first used.
-- These instructions are known as the font program. The main use of this table
-- is for the definition of functions that are used in many different glyph programs.
return r.Struct.new({
  instructions = r.Array.new(r.uint8)
})
