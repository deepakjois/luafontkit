local r = require('restructure')

local Signature = r.Struct.new({
  { format = r.uint32 },
  { length = r.uint32 },
  { offset = r.uint32 }
})

local SignatureBlock = r.Struct.new({
  { reserved =       r.Reserved.new(r.uint16, 2) },
  { cbSignature =    r.uint32 },  -- Length (in bytes) of the PKCS#7 packet in pbSignature
  { signature =      r.Buffer.new('cbSignature') }
})

return r.Struct.new({
  { ulVersion =       r.uint32 },  -- Version number of the DSIG table (0x00000001)
  { usNumSigs =       r.uint16 },  -- Number of signatures in the table
  { usFlag =          r.uint16 },  -- Permission flags
  { signatures =      r.Array.new(Signature, 'usNumSigs') },
  { signatureBlocks = r.Array.new(SignatureBlock, 'usNumSigs') }
})
