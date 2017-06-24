local r = require('restructure')
local opentype = require('fontkit.tables.opentype')
local LookupList = opentype.LookupList

local GPOSLookup = require('fontkit.tables.GPOS').GPOSLookup

local JstfGSUBModList = r.Array.new(r.uint16, r.uint16)

local JstfPriority = r.Struct.new({
  { shrinkageEnableGSUB =    r.Pointer.new(r.uint16, JstfGSUBModList) },
  { shrinkageDisableGSUB =   r.Pointer.new(r.uint16, JstfGSUBModList) },
  { shrinkageEnableGPOS =    r.Pointer.new(r.uint16, JstfGSUBModList) },
  { shrinkageDisableGPOS =   r.Pointer.new(r.uint16, JstfGSUBModList) },
  { shrinkageJstfMax =       r.Pointer.new(r.uint16, LookupList.new(GPOSLookup)) },
  { extensionEnableGSUB =    r.Pointer.new(r.uint16, JstfGSUBModList) },
  { extensionDisableGSUB =   r.Pointer.new(r.uint16, JstfGSUBModList) },
  { extensionEnableGPOS =    r.Pointer.new(r.uint16, JstfGSUBModList) },
  { extensionDisableGPOS =   r.Pointer.new(r.uint16, JstfGSUBModList) },
  { extensionJstfMax =       r.Pointer.new(r.uint16, LookupList.new(GPOSLookup)) }
})

local JstfLangSys = r.Array.new(r.Pointer.new(r.uint16, JstfPriority), r.uint16)

local JstfLangSysRecord = r.Struct.new({
  { tag =         r.String.new(4) },
  { jstfLangSys = r.Pointer.new(r.uint16, JstfLangSys) }
})

local JstfScript = r.Struct.new({
  { extenderGlyphs = r.Pointer.new(r.uint16, r.Array.new(r.uint16, r.uint16)) }, -- array of glyphs to extend line length
  { defaultLangSys = r.Pointer.new(r.uint16, JstfLangSys) },
  { langSysCount =   r.uint16 },
  { langSysRecords = r.Array.new(JstfLangSysRecord, 'langSysCount') }
})

local JstfScriptRecord = r.Struct.new({
  { tag =    r.String.new(4) },
  { script = r.Pointer.new(r.uint16, JstfScript, {type = 'parent'}) }
})

return r.Struct.new({
  { version =     r.uint32 },  -- should be 0x00010000
  { scriptCount = r.uint16 },
  { scriptList =  r.Array.new(JstfScriptRecord, 'scriptCount') }
})
