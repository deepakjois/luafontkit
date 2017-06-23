local r = require('restructure')
local opentype = require('fontkit.tables.opentype')
local Coverage = opentype.Coverage
local ClassDef = opentype.ClassDef
local Device = opentype.Device

local ItemVariationStore = require('fontkit.tables.variations').ItemVariationStore

local AttachPoint = r.Array.new(r.uint16, r.uint16)
local AttachList = r.Struct.new({
  { coverage =       r.Pointer.new(r.uint16, Coverage) },
  { glyphCount =     r.uint16 },
  { attachPoints =   r.Array.new(r.Pointer.new(r.uint16, AttachPoint), 'glyphCount') }
})

local CaretValue = r.VersionedStruct.new(r.uint16, {
  [1] = { -- Design units only
    { coordinate = r.int16 }
  },

  [2] = { -- Contour point
    { caretValuePoint = r.uint16 }
  },

  [3] = { -- Design units plus Device table
    { coordinate =     r.int16 },
    { deviceTable =    r.Pointer.new(r.uint16, Device) }
  }
})

local LigGlyph = r.Array.new(r.Pointer.new(r.uint16, CaretValue), r.uint16)

local LigCaretList = r.Struct.new({
  { coverage =       r.Pointer.new(r.uint16, Coverage) },
  { ligGlyphCount =  r.uint16 },
  { ligGlyphs =      r.Array.new(r.Pointer.new(r.uint16, LigGlyph), 'ligGlyphCount') }
})

local MarkGlyphSetsDef = r.Struct.new({
  { markSetTableFormat = r.uint16 },
  { markSetCount =       r.uint16 },
  { coverage =           r.Array.new(r.Pointer.new(r.uint32, Coverage), 'markSetCount') }
})

return r.VersionedStruct.new(r.uint32, {
  header = {
    { glyphClassDef =      r.Pointer.new(r.uint16, ClassDef) },
    { attachList =         r.Pointer.new(r.uint16, AttachList) },
    { ligCaretList =       r.Pointer.new(r.uint16, LigCaretList) },
    { markAttachClassDef = r.Pointer.new(r.uint16, ClassDef) }
  },

  [0x00010000] = {},
  [0x00010002]  = {
    { markGlyphSetsDef =   r.Pointer.new(r.uint16, MarkGlyphSetsDef) }
  },
  [0x00010003] = {
    { markGlyphSetsDef =   r.Pointer.new(r.uint16, MarkGlyphSetsDef) },
    { itemVariationStore = r.Pointer.new(r.uint32, ItemVariationStore) }
  }
})
