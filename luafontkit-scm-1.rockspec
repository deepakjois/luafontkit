package = "luafontkit"
version = "scm-1"
source = {
   url = "git+https://github.com/deepakjois/luafontkit.git"
}
description = {
   summary = "An advanced font engine for Lua",
   detailed = "Fontkit is an advanced font engine for Lua, ported from Javascript. It supports many font formats, advanced glyph substitution and layout features, glyph path extraction, color emoji glyphs, font subsetting, and more.",
   homepage = "https://github.com/deepakjois/luafontkit",
   license = "MIT"
}
dependencies = {
   "lua >= 5.2, < 5.4"
}
build = {
   type = "builtin",
   modules = {}
}
