local r = require('restructure')

local SubHeader = r.Struct.new({
  { firstCode =      r.uint16 },
  { entryCount =     r.uint16 },
  { idDelta =        r.int16 },
  { idRangeOffset =  r.uint16 }
})

local CmapGroup = r.Struct.new({
  { startCharCode =  r.uint32 },
  { endCharCode =    r.uint32 },
  { glyphID =        r.uint32 }
})

local UnicodeValueRange = r.Struct.new({
  { startUnicodeValue =  r.uint24 },
  { additionalCount =    r.uint8 }
})

local UVSMapping = r.Struct.new({
  { unicodeValue = r.uint24 },
  { glyphID =      r.uint16 }
})

local DefaultUVS = r.Array.new(UnicodeValueRange, r.uint32)
local NonDefaultUVS = r.Array.new(UVSMapping, r.uint32)

local VarSelectorRecord = r.Struct.new({
  { varSelector =    r.uint24 },
  { defaultUVS =     r.Pointer.new(r.uint32, DefaultUVS, {type = 'parent'}) },
  { nonDefaultUVS =  r.Pointer.new(r.uint32, NonDefaultUVS, {type = 'parent'}) }
})

local CmapSubtable = r.VersionedStruct.new(r.uint16, {
  [0] = { -- Byte encoding
    { length =     r.uint16 },   -- Total table length in bytes (set to 262 for format 0)
    { language =   r.uint16 },   -- Language code for this encoding subtable, or zero if language-independent
    { codeMap =    r.LazyArray.new(r.uint8, 256) }
  },

  [2] = { -- High-byte mapping (CJK)
    { length =           r.uint16 },
    { language =         r.uint16 },
    { subHeaderKeys =    r.Array.new(r.uint16, 256) },
    { subHeaderCount =   function(t) return math.max(table.unpack(t.subHeaderKeys)) end },
    { subHeaders =       r.LazyArray.new(SubHeader, 'subHeaderCount') },
    { glyphIndexArray =  r.LazyArray.new(r.uint16, 'subHeaderCount') }
  },

  [4] = { -- Segment mapping to delta values
    { length =           r.uint16 },              -- Total table length in bytes
    { language =         r.uint16 },              -- Language code
    { segCountX2 =       r.uint16 },
    { segCount =         function(t) return math.floor(t.segCountX2/2) end },
    { searchRange =      r.uint16 },
    { entrySelector =    r.uint16 },
    { rangeShift =       r.uint16 },
    { endCode =          r.LazyArray.new(r.uint16, 'segCount') },
    { reservedPad =      r.Reserved.new(r.uint16) },       -- This value should be zero
    { startCode =        r.LazyArray.new(r.uint16, 'segCount') },
    { idDelta =          r.LazyArray.new(r.int16, 'segCount') },
    { idRangeOffset =    r.LazyArray.new(r.uint16, 'segCount') },
    { glyphIndexArray =  r.LazyArray.new(r.uint16, function(t) return (t.length - t._currentOffset) / 2 end) }
  },

  [6] = { -- Trimmed table
    { length =         r.uint16 },
    { language =       r.uint16 },
    { firstCode =      r.uint16 },
    { entryCount =     r.uint16 },
    { glyphIndices =   r.LazyArray.new(r.uint16, 'entryCount') }
  },

  [8] = { -- mixed 16-bit and 32-bit coverage
    { reserved = r.Reserved.new(r.uint16) },
    { length =   r.uint32 },
    { language = r.uint16 },
    { is32 =     r.LazyArray.new(r.uint8, 8192) },
    { nGroups =  r.uint32 },
    { groups =   r.LazyArray.new(CmapGroup, 'nGroups') }
  },

  [10] = { -- Trimmed Array
    { reserved =       r.Reserved.new(r.uint16) },
    { length =         r.uint32 },
    { language =       r.uint32 },
    { firstCode =      r.uint32 },
    { entryCount =     r.uint32 },
    { glyphIndices =   r.LazyArray.new(r.uint16, 'numChars') }
  },

  [12] = { -- Segmented coverage
    { reserved = r.Reserved.new(r.uint16) },
    { length =   r.uint32 },
    { language = r.uint32 },
    { nGroups =  r.uint32 },
    { groups =   r.LazyArray.new(CmapGroup, 'nGroups') }
  },

  [13] = { -- Many-to-one range mappings (same as 12 except for group.startGlyphID)
    { reserved = r.Reserved.new(r.uint16) },
    { length =   r.uint32 },
    { language = r.uint32 },
    { nGroups =  r.uint32 },
    { groups =   r.LazyArray.new(CmapGroup, 'nGroups') }
  },

  [14] = { -- Unicode Variation Sequences
    { length =       r.uint32 },
    { numRecords =   r.uint32 },
    { varSelectors = r.LazyArray.new(VarSelectorRecord, 'numRecords') }
  }
})

local CmapEntry = r.Struct.new({
  { platformID =  r.uint16 },  -- Platform identifier
  { encodingID =  r.uint16 },  -- Platform-specific encoding identifier
  { table =       r.Pointer.new(r.uint32, CmapSubtable, {type = 'parent', lazy = true}) }
})

-- character to glyph mapping
return r.Struct.new({
  { version =      r.uint16 },
  { numSubtables = r.uint16 },
  { tables =       r.Array.new(CmapEntry, 'numSubtables') }
})
