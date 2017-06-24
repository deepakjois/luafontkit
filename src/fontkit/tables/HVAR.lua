local r = require('restructure')
local resolveLength = require('restructure.utils').resolveLength
local ItemVariationStore = require('fontkit.tables.variations').ItemVariationStore

-- TODO: add this to restructure
local VariableSizeNumber = {}
VariableSizeNumber.__index = VariableSizeNumber

function VariableSizeNumber.new(size)
  local vn = setmetatable({}, VariableSizeNumber)
  vn._size = size

  return vn
end

function VariableSizeNumber:decode(stream, parent)
  local v = self:size(0, parent)
  if v == 1 then return stream:readUInt8()
  elseif v == 2 then return stream:readUInt16BE()
  elseif v == 3 then return stream:readUInt24BE()
  elseif v == 4 then return stream:readUInt32BE() end
end

function VariableSizeNumber:size(_, parent)
  return resolveLength(self._size, nil, parent)
end

local MapDataEntry = r.Struct.new({
  { entry = VariableSizeNumber.new(function(t) return  bit32.rshift(bit32.band(t.parent.entryFormat, 0x0030), 4) + 1 end) },
  { outerIndex = function(t) return  bit32.rshift(t.entry, (bit32.band(t.parent.entryFormat, 0x000F) + 1)) end },
  { innerIndex = function(t) return  bit32.band(t.entry, (bit32.lshift(1, ((t.parent.entryFormat & 0x000F) + 1)) - 1)) end }
})

local DeltaSetIndexMap = r.Struct.new({
  { entryFormat = r.uint16 },
  { mapCount = r.uint16 },
  { mapData = r.Array.new(MapDataEntry, 'mapCount') }
})

return r.Struct.new({
  { majorVersion = r.uint16 },
  { minorVersion = r.uint16 },
  { itemVariationStore = r.Pointer.new(r.uint32, ItemVariationStore) },
  { advanceWidthMapping = r.Pointer.new(r.uint32, DeltaSetIndexMap) },
  { LSBMapping = r.Pointer.new(r.uint32, DeltaSetIndexMap) },
  { RSBMapping = r.Pointer.new(r.uint32, DeltaSetIndexMap) }
})
