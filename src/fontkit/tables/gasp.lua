local r = require('restructure')

local GaspRange = r.Struct.new({
  { rangeMaxPPEM =       r.uint16 },                  -- Upper limit of range, in ppem
  { rangeGaspBehavior =  r.Bitfield.new(r.uint16, { -- Flags describing desired rasterizer behavior
    'grayscale', 'gridfit',
    'symmetricSmoothing', 'symmetricGridfit'     -- only in version 1, for ClearType
  }) }
})

return r.Struct.new({
  { version =    r.uint16 },  -- set to 0
  { numRanges =  r.uint16 },
  { gaspRanges = r.Array.new(GaspRange, 'numRanges') } -- Sorted by ppem
})
