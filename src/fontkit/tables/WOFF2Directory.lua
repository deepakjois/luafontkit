local r = require('restructure')

local Base128 = {}
function Base128.decode(stream)
  local result = 0
  for _ = 1,5 do
    local code = stream:readUInt8()

    -- If any of the top seven bits are set then we're about to overflow.
    if bit32.band(result, 0xe0000000) then error('Overflow') end

    result = bit32.bor(bit32.lshift(result, 7), bit32.band(code,0x7f))
    if bit32.band(code, 0x80) == 0 then return result end

    error('Bad base 128 number')
  end
end

local knownTags = {
  'cmap', 'head', 'hhea', 'hmtx', 'maxp', 'name', 'OS/2', 'post', 'cvt ',
  'fpgm', 'glyf', 'loca', 'prep', 'CFF ', 'VORG', 'EBDT', 'EBLC', 'gasp',
  'hdmx', 'kern', 'LTSH', 'PCLT', 'VDMX', 'vhea', 'vmtx', 'BASE', 'GDEF',
  'GPOS', 'GSUB', 'EBSC', 'JSTF', 'MATH', 'CBDT', 'CBLC', 'COLR', 'CPAL',
  'SVG ', 'sbix', 'acnt', 'avar', 'bdat', 'bloc', 'bsln', 'cvar', 'fdsc',
  'feat', 'fmtx', 'fvar', 'gvar', 'hsty', 'just', 'lcar', 'mort', 'morx',
  'opbd', 'prop', 'trak', 'Zapf', 'Silf', 'Glat', 'Gloc', 'Feat', 'Sill'
}

local WOFF2DirectoryEntry = r.Struct.new({
  { flags = r.uint8 },
  { customTag = r.Optional.new(r.String.new(4), function(t) return  bit32.band(t.flags, 0x3f) == 0x3f end) },
  { tag = function(t) return  t.customTag or knownTags[bit32.band(t.flags, 0x3f)] end },-- || (() => { throw Error.new(`Bad tag = ${flags & 0x3f}`) })() },
  { length = Base128 },
  { transformVersion = function(t) return  bit32.band(bit32.arshift(t.flags, 6), 0x03) end },
  { transformed = function(t)
    if t.tag == 'glyf' or t.tag == 'loca' then
      return t.transformVersion == 0
    else
      return t.transformVersion ~= 0
    end
  end },
  { transformLength = r.Optional.new(Base128, function(t) return t.transformed end) }
})

local WOFF2Directory = r.Struct.new({
  { tag = r.String.new(4) }, -- should be 'wOF2'
  { flavor = r.uint32 },
  { length = r.uint32 },
  { numTables = r.uint16 },
  { reserved = r.Reserved.new(r.uint16) },
  { totalSfntSize = r.uint32 },
  { totalCompressedSize = r.uint32 },
  { majorVersion = r.uint16 },
  { minorVersion = r.uint16 },
  { metaOffset = r.uint32 },
  { metaLength = r.uint32 },
  { metaOrigLength = r.uint32 },
  { privOffset = r.uint32 },
  { privLength = r.uint32 },
  { tables = r.Array.new(WOFF2DirectoryEntry, 'numTables') }
})

function WOFF2Directory.process(this)
  local tables = {}
  for _,table in ipairs(this.tables) do
    tables[table.tag] = table
  end

  this.tables = tables
  return tables
end

return WOFF2Directory
