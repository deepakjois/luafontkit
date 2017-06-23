local fontkit = require('fontkit.base')
local TTFFont = require('fontkit.TTFFont')
local WOFFFont = require('fontkit.WOFFFont')
local WOFF2Font = require('fontkit.WOFF2Font')
local TrueTypeCollection = require('fontkit.TrueTypeCollection')
local DFont = require('fontkit.DFont')

-- Register font formats
fontkit.registerFormat(TTFFont)
fontkit.registerFormat(WOFFFont)
fontkit.registerFormat(WOFF2Font)
fontkit.registerFormat(TrueTypeCollection)
fontkit.registerFormat(DFont)

return fontkit
