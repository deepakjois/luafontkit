local r = require('restructure')
local encodings = require('fontkit.encodings')
local getEncoding = encodings.getEncoding
local LANGUAGES = encodings.LANGUAGES

local NameRecord = r.Struct.new({
  { platformID = r.uint16 },
  { encodingID = r.uint16 },
  { languageID = r.uint16 },
  { nameID =     r.uint16 },
  { length =     r.uint16 },
  { string =     r.Pointer.new(r.uint16,
    r.String.new('length', function(t) return  getEncoding(t.platformID, t.encodingID, t.languageID) end),
    { type = 'parent', relativeTo = 'parent.stringOffset', allowNull = false }
  ) }
})

local LangTagRecord = r.Struct.new({
  { length =  r.uint16 },
  { tag =     r.Pointer.new(r.uint16, r.String.new('length', 'utf16be'), {type = 'parent', relativeTo = 'stringOffset'}) }
})

local NameTable = r.VersionedStruct.new(r.uint16, {
  [0] = {
    { count =          r.uint16 },
    { stringOffset =   r.uint16 },
    { records =        r.Array.new(NameRecord, 'count') }
  },
  [1] = {
    { count =          r.uint16 },
    { stringOffset =   r.uint16 },
    { records =        r.Array.new(NameRecord, 'count') },
    { langTagCount =   r.uint16 },
    { langTags =       r.Array.new(LangTagRecord, 'langTagCount') }
  }
})

local NAMES = {
  'copyright',
  'fontFamily',
  'fontSubfamily',
  'uniqueSubfamily',
  'fullName',
  'version',
  'postscriptName', -- Note = A font may have only one PostScript name and that name must be ASCII.
  'trademark',
  'manufacturer',
  'designer',
  'description',
  'vendorURL',
  'designerURL',
  'license',
  'licenseURL',
  nil, -- reserved
  'preferredFamily',
  'preferredSubfamily',
  'compatibleFull',
  'sampleText',
  'postscriptCIDFontName',
  'wwsFamilyName',
  'wwsSubfamilyName'
}

function NameTable.process(this)
  local records = {}
  for _, record in this.records do
    -- find out what language this is for
    local language = LANGUAGES[record.platformID][record.languageID]

    if language == nil and this.langTags ~= nil and record.languageID >= 0x8000 then
      language = this.langTags[record.languageID - 0x8000].tag
    end

    if language == nil then
      language = record.platformID + '-' + record.languageID
    end

    -- if the nameID is >= 256, it is a font feature record (AAT)
    local key
    if record.nameID >= 256 then
      key = 'fontFeatures'
    else
      key = NAMES[record.nameID] or record.nameID
    end

    if records[key] == nil then
      records[key] = {}
    end

    local obj = records[key]
    if record.nameID >= 256 then
      if not obj[record.nameID] then obj[record.nameID] = {} end
      obj = obj[record.nameID]
    end

    if type(record.string) == 'string' or type(obj[language]) ~= 'string' then
      obj[language] = record.string
    end
  end

  this.records = records
end

function NameTable.preEncode(this)
  if type(this.records) == 'table' then return end
  this.version = 0

  local records = {}
  for key,_ in pairs(this.records) do
    local val = this.records[key]
    if (key ~= 'fontFeatures') then
      table.insert(records,{
        platformID = 3,
        encodingID = 1,
        languageID = 0x409,
        nameID = NAMES.indexOf(key), -- FIXME
        length = #val,
        string = val.en
      })

      if (key == 'postscriptName') then
        table.insert(records,{
          platformID = 1,
          encodingID = 0,
          languageID = 0,
          nameID = NAMES.indexOf(key), -- FIXME
          length = #val.en,
          string = val.en
        })
      end
    end
  end

  this.records = records
  this.count = records.length
  this.stringOffset = NameTable.size(this, nil, false)
end

return NameTable