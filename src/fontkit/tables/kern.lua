local r = require('restructure')

local KernPair = r.Struct.new({
  { left =   r.uint16 },
  { right =  r.uint16 },
  { value =  r.int16 }
})

local ClassTable = r.Struct.new({
  { firstGlyph = r.uint16 },
  { nGlyphs = r.uint16 },
  { offsets = r.Array.new(r.uint16, 'nGlyphs') },
  { max = function(t) return  t.offsets.length and math.max(table.unpack(t.offsets)) end }
})

local Kern2Array = r.Struct.new({
  { off = function(t) return  t._startOffset - t.parent.parent._startOffset end },
  { len = function(t) return  (((t.parent.leftTable.max - t.off) / t.parent.rowWidth) + 1) * (t.parent.rowWidth / 2) end },
  { values = r.LazyArray.new(r.int16, 'len') }
})

local KernSubtable = r.VersionedStruct.new('format', {
  [0] = {
    { nPairs =         r.uint16 },
    { searchRange =    r.uint16 },
    { entrySelector =  r.uint16 },
    { rangeShift =     r.uint16 },
    { pairs =          r.Array.new(KernPair, 'nPairs') }
  },

  [2] = {
    { rowWidth =   r.uint16 },
    { leftTable =  r.Pointer.new(r.uint16, ClassTable, {type = 'parent'}) },
    { rightTable = r.Pointer.new(r.uint16, ClassTable, {type = 'parent'}) },
    { array =      r.Pointer.new(r.uint16, Kern2Array, {type = 'parent'}) }
  },

  [3] = {
    { glyphCount =       r.uint16 },
    { kernValueCount =   r.uint8 },
    { leftClassCount =   r.uint8 },
    { rightClassCount =  r.uint8 },
    { flags =            r.uint8 },
    { kernValue =        r.Array.new(r.int16, 'kernValueCount') },
    { leftClass =        r.Array.new(r.uint8, 'glyphCount') },
    { rightClass =       r.Array.new(r.uint8, 'glyphCount') },
    { kernIndex =        r.Array.new(r.uint8, function(t) return  t.leftClassCount * t.rightClassCount end) }
  }
})

local KernTable = r.VersionedStruct.new('version', {
  [0] = { -- Microsoft uses this format
    { subVersion = r.uint16 },  -- Microsoft has an extra sub-table version number
    { length =     r.uint16 },  -- Length of the subtable, in bytes
    { format =     r.uint8 },   -- Format of subtable
    { coverage =   r.Bitfield.new(r.uint8, {
      'horizontal',    -- 1 if table has horizontal data, 0 if vertical
      'minimum',       -- If set to 1, the table has minimum values. If set to 0, the table has kerning values.
      'crossStream',   -- If set to 1, kerning is perpendicular to the flow of the text
      'override'      -- If set to 1 the value in this table replaces the accumulated value
    }) },
    { subtable =   KernSubtable },
    { padding = r.Reserved.new(r.uint8, function(t) return  t.length - t._currentOffset end) }
  },
  [1] = { -- Apple uses this format
    { length =     r.uint32 },
    { coverage =   r.Bitfield.new(r.uint8, {
      nil, nil, nil, nil, nil,
      'variation',     -- Set if table has variation kerning values
      'crossStream',   -- Set if table has cross-stream kerning values
      'vertical'      -- Set if table has vertical kerning values
    }) },
    format =     r.uint8,
    tupleIndex = r.uint16,
    subtable =   KernSubtable,
    padding = r.Reserved.new(r.uint8, function(t) return  t.length - t._currentOffset end)
  }
})

return r.VersionedStruct.new(r.uint16, {
  [0] = { -- Microsoft Version
    { nTables =    r.uint16 },
    { tables =     r.Array.new(KernTable, 'nTables') }
  },

  [1] = { -- Apple Version
    { reserved =   r.Reserved.new(r.uint16) }, -- the other half of the version number
    { nTables =    r.uint32 },
    { tables =     r.Array.new(KernTable, 'nTables') }
  }
})
