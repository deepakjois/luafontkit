local r = require('restructure')

local UnboundedArrayAccessor = {}
UnboundedArrayAccessor.__index = UnboundedArrayAccessor

function UnboundedArrayAccessor.new(type, stream, parent)
  local ua = setmetatable({}, UnboundedArrayAccessor)
  ua.type = type
  ua.stream = stream
  ua.parent = parent
  ua.base = ua.stream.buffer.pos
  ua._items = {}
end

function UnboundedArrayAccessor:getItem(index)
  if self._items[index] == nil then
    local pos = self.stream.pos
    self.stream.pos = self.base + self.type:size(nil, self.parent) * index
    self._items[index] = self.type:decode(self.stream, self.parent)
    self.stream.pos = pos
  end

  return self._items[index]
end

local UnboundedArray = setmetatable({}, r.Array)
UnboundedArray.__index = UnboundedArray

function UnboundedArray.new(type)
  return r.Array.new(type, 0)
end

function UnboundedArray:decode(stream, parent)
  return UnboundedArrayAccessor.new(self.type, stream, parent)
end

local LookupTable = function(ValueType)
  if ValueType == nil then ValueType = r.uint16 end

  local Shadow = {}
  Shadow.__index = Shadow

  function Shadow.new(type)
    local s = setmetatable({}, Shadow)
    s.type = type
    return s
  end

  function Shadow:decode(stream, ctx)
    ctx = ctx.parent.parent
    return self.type:decode(stream, ctx)
  end

  function Shadow:encode(stream, val, ctx)
    ctx = ctx.parent.parent
    return self.type:encode(stream, val, ctx)
  end

  ValueType = Shadow.new(ValueType)

  local BinarySearchHeader = r.Struct.new({
    { unitSize = r.uint16 },
    { nUnits = r.uint16 },
    { searchRange = r.uint16 },
    { entrySelector = r.uint16 },
    { rangeShift = r.uint16 }
  })

  local LookupSegmentSingle = r.Struct.new({
    { lastGlyph = r.uint16 },
    { firstGlyph = r.uint16 },
    { value = ValueType }
  })

  local LookupSegmentArray = r.Struct.new({
    { lastGlyph = r.uint16 },
    { firstGlyph = r.uint16 },
    { values = r.Pointer.new(r.uint16, r.Array.new(ValueType, function(t) return t.lastGlyph - t.firstGlyph + 1 end), {type = 'parent'})}
  })

  local LookupSingle = r.Struct.new({
    { glyph = r.uint16 },
    { value = ValueType }
  })

  return r.VersionedStruct.new(r.uint16, {
    [0] = {
      {values = UnboundedArray.new(ValueType)} -- length == number of glyphs maybe?
    },
    [2] = {
      { binarySearchHeader = BinarySearchHeader },
      { segments = r.Array.new(LookupSegmentSingle, function(t) return t.binarySearchHeader.nUnits end) }
    },
    [4] = {
      { binarySearchHeader = BinarySearchHeader },
      { segments = r.Array.new(LookupSegmentArray, function(t) return t.binarySearchHeader.nUnits end) }
    },
    [6] = {
      { binarySearchHeader = BinarySearchHeader },
      { segments = r.Array.new(LookupSingle, function(t) return t.binarySearchHeader.nUnits end) }
    },
    [8] = {
      { firstGlyph = r.uint16 },
      { count = r.uint16 },
      { values = r.Array.new(ValueType, 'count') }
    }
  })
end

local function StateTable(entryData, lookupType)
  if not entryData then entryData = {} end
  if not lookupType then lookupType = r.uint16 end

  local entry = {
    { newState = r.uint16 },
    { flags = r.uint16 }
  }

  for _,v in ipairs(entryData) do
    table.insert(entry, v)
  end

  local Entry = r.Struct.new(entry)
  local StateArray = UnboundedArray.new(r.Array.new(r.uint16, function(t) return t.nClasses end))

  local StateHeader = r.Struct.new({
   { nClasses = r.uint32 },
   { classTable = r.Pointer.new(r.uint32, LookupTable.new(lookupType)) },
   { stateArray = r.Pointer.new(r.uint32, StateArray) },
   { entryTable = r.Pointer.new(r.uint32, UnboundedArray.new(Entry)) }
  })

  return StateHeader
end

-- This is the old version of the StateTable structure
local function StateTable1(entryData)
  if not entryData then entryData = {} end

  local ClassLookupTable = r.Struct.new({
    { version = function() return 8 end }, -- simulate LookupTable
    { firstGlyph = r.uint16 },
    { values = r.Array.new(r.uint8, r.uint16) }
  })

  local entry = {
    { newStateOffset = r.uint16 },
    -- convert offset to stateArray index
    { newState = function(t) return (t.newStateOffset - (t.parent.stateArray.base - t.parent._startOffset)) / t.parent.nClasses end },
    { flags = r.uint16 }
  }

  for _,v in ipairs(entryData) do
    table.insert(entry, v)
  end

  local Entry = r.Struct.new(entry)
  local StateArray = UnboundedArray.new(r.Array.new(r.uint8, function(t) return t.nClasses end))

  local StateHeader1 = r.Struct.new({
    { nClasses = r.uint16 },
    { classTable = r.Pointer.new(r.uint16, ClassLookupTable) },
    { stateArray = r.Pointer.new(r.uint16, StateArray) },
    { entryTable = r.Pointer(r.uint16, UnboundedArray.new(Entry)) }
  })

  return StateHeader1
end

return {
  UnboundedArray = UnboundedArray,
  LookupTable = LookupTable,
  StateTable = StateTable,
  StateTable1 = StateTable1
}
