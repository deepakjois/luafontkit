local r = require('restructure')

local fontkit = {}

fontkit.logErrors = false

local formats = {}

fontkit.registerFormat = function(format)
  table.insert(formats, format)
end

fontkit.open = function(filename, postscriptName)
  local buffer = io.open(filename)
  return fontkit.create(buffer, postscriptName)
end

fontkit.create = function(buffer, postscriptName)
  for _,format  in ipairs(formats) do
    if format.probe(buffer) then
      local font = format.new(r.DecodeStream.new(buffer))
      if (postscriptName) then
        return font.getFont(postscriptName)
      end
      return font
    end
  end
  error('Unknown font format')
end

return fontkit
