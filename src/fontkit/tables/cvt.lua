local r = require('restructure')

-- An array of predefined values accessible by instructions
return r.Struct.new({
  controlValues = r.Array.new(r.int16)
})
