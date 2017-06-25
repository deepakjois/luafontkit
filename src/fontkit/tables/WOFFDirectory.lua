local r = require('restructure')


local WOFFDirectoryEntry = r.Struct.new({
  { tag =          r.String.new(4) },
  { offset =       r.Pointer.new(r.uint32, 'void', {type = 'global'}) },
  { compLength =   r.uint32 },
  { length =       r.uint32 },
  { origChecksum = r.uint32 }
})

local WOFFDirectory = r.Struct.new({
  { tag =            r.String.new(4) }, -- should be 'wOFF'
  { flavor =         r.uint32 },
  { length =         r.uint32 },
  { numTables =      r.uint16 },
  { reserved =       r.Reserved.new(r.uint16) },
  { totalSfntSize =  r.uint32 },
  { majorVersion =   r.uint16 },
  { minorVersion =   r.uint16 },
  { metaOffset =     r.uint32 },
  { metaLength =     r.uint32 },
  { metaOrigLength = r.uint32 },
  { privOffset =     r.uint32 },
  { privLength =     r.uint32 },
  { tables =         r.Array.new(WOFFDirectoryEntry, 'numTables') }
})

function WOFFDirectory.process(this)
  local tables = {}
  for _,table in ipairs(this.tables) do
    tables[table.tag] = table
  end

  this.tables = tables
end

return WOFFDirectory
