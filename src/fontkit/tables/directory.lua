local r = require('restructure')
local Tables = require("fontkit.tables")

local TableEntry = r.Struct.new({
  { tag =        r.String.new(4) },
  { checkSum =   r.uint32 },
  { offset =     r.Pointer.new(r.uint32, 'void', { type = 'global' }) },
  { length =     r.uint32 }
})

local Directory = r.Struct.new({
  { tag =            r.String.new(4) },
  { numTables =      r.uint16 },
  { searchRange =    r.uint16 },
  { entrySelector =  r.uint16 },
  { rangeShift =     r.uint16 },
  { tables =         r.Array.new(TableEntry, 'numTables') }
})

function Directory.process(this)
  local tables = {}
  for _,table_ in pairs(this.tables) do
    tables[table_.tag] = table_
  end

  this.tables = tables
end

function Directory.preEncode(this)
  local tables = {}
  for _,tag in pairs(this.tables) do
    local table_ = this.tables[tag]
    if table_ then
      table.insert(tables, {
        tag = tag,
        checkSum = 0,
        offset = r.VoidPointer.new(Tables[tag], table_),
        length = Tables[tag].size(table_)
      })
    end
  end

  this.tag = 'true'
  this.numTables = #tables
  this.tables = tables

  this.searchRange = math.floor(math.log(this.numTables) / math.log(2)) * 16
  this.entrySelector = math.floor(this.searchRange / math.log(2))
  this.rangeShift = this.numTables * 16 - this.searchRange
end

return Directory
