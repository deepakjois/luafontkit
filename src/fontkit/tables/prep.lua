local r = require('restructure')

-- Set of instructions executed whenever the point size or font transformation change
return r.Struct.new({
  { controlValueProgram = r.Array.new(r.uint8) }
})
