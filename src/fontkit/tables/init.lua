local tables = {}

-- Required Tables
local cmap = require('fontkit.tables.cmap')
local head = require('fontkit.tables.head')
local hhea = require('fontkit.tables.hhea')
local hmtx = require('fontkit.tables.hmtx')
local maxp = require('fontkit.tables.maxp')
local name = require('fontkit.tables.name')
local OS2 = require('fontkit.tables.OS2')
local post = require('fontkit.tables.post')

tables.cmap = cmap
tables.head = head
tables.hhea = hhea
tables.hmtx = hmtx
tables.maxp = maxp
tables.name = name
tables['OS/2'] = OS2
tables.post = post


-- TrueType Outlines
local cvt = require('fontkit.tables.cvt')
local fpgm = require('fontkit.tables.fpgm')
local loca = require('fontkit.tables.loca')
local prep = require('fontkit.tables.prep')
local glyf = require('fontkit.tables.glyf')

tables.fpgm = fpgm
tables.loca = loca
tables.prep = prep
tables['cvt '] = cvt
tables.glyf = glyf


-- PostScript Outlines
local CFFFont = require('../cff/CFFFont')
local VORG = require('fontkit.tables.VORG')

tables['CFF '] = CFFFont
tables['CFF2'] = CFFFont
tables.VORG = VORG


-- Bitmap Glyphs
local EBLC = require('fontkit.tables.EBLC')
local sbix = require('fontkit.tables.sbix')
local COLR = require('fontkit.tables.COLR')
local CPAL = require('fontkit.tables.CPAL')

tables.EBLC = EBLC
tables.CBLC = tables.EBLC
tables.sbix = sbix
tables.COLR = COLR
tables.CPAL = CPAL


-- Advanced OpenType Tables
local BASE = require('fontkit.tables.BASE')
local GDEF = require('fontkit.tables.GDEF')
local GPOS = require('fontkit.tables.GPOS').GPOS
local GSUB = require('fontkit.tables.GSUB')
local JSTF = require('fontkit.tables.JSTF')

tables.BASE = BASE
tables.GDEF = GDEF
tables.GPOS = GPOS
tables.GSUB = GSUB
tables.JSTF = JSTF

-- OpenType variations tables
local HVAR = require('fontkit.tables.HVAR')

tables.HVAR = HVAR

-- Other OpenType Tables
local DSIG = require('fontkit.tables.DSIG')
local gasp = require('fontkit.tables.gasp')
local hdmx = require('fontkit.tables.hdmx')
local kern = require('fontkit.tables.kern')
local LTSH = require('fontkit.tables.LTSH')
local PCLT = require('fontkit.tables.PCLT')
local VDMX = require('fontkit.tables.VDMX')
local vhea = require('fontkit.tables.vhea')
local vmtx = require('fontkit.tables.vmtx')

tables.DSIG = DSIG
tables.gasp = gasp
tables.hdmx = hdmx
tables.kern = kern
tables.LTSH = LTSH
tables.PCLT = PCLT
tables.VDMX = VDMX
tables.vhea = vhea
tables.vmtx = vmtx


-- Apple Advanced Typography Tables
local avar = require('fontkit.tables.avar')
local bsln = require('fontkit.tables.bsln')
local feat = require('fontkit.tables.feat')
local fvar = require('fontkit.tables.fvar')
local gvar = require('fontkit.tables.gvar')
local just = require('fontkit.tables.just')
local morx = require('fontkit.tables.morx')
local opbd = require('fontkit.tables.opbd')

tables.avar = avar
tables.bsln = bsln
tables.feat = feat
tables.fvar = fvar
tables.gvar = gvar
tables.just = just
tables.morx = morx
tables.opbd = opbd

return tables
