local r = require('restructure')

local loca = r.VersionedStruct.new('head.indexToLocFormat', {
  [0] = {
    { offsets = r.Array.new(r.uint16) }
  },
  [1] = {
    { offsets = r.Array.new(r.uint32) }
  }
})

function loca.process(this)
  if this.version == 0 then
    for i,v in ipairs(this.offsets) do
      this.offsets[i] = bit32.lshift(v, 1)
    end
  end
end

function loca.preEncode(this)
  if this.version ~= nil then return end

  -- assume this.offsets is a sorted array
  if this.offsets[#this.offsets] > 0xffff then
    this.version = 1
  else
    this.version = 0
  end

  if this.version == 0 then
    for i,v in ipairs(this.offsets) do
      this.offsets[i] = bit32.arshift(v,1)
    end
  end
end

return loca
