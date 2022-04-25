-- Imports
local libmodal = require 'libmodal'

-- Register key commands and what they do.
local fooModeKeymaps =
{
	[''] = 'echom "You cant exit using escape."',
	q = 'let g:fooModeExit = 1'
}

-- Tell the mode not to exit automatically.
vim.g.fooModeExit = false

-- Enter the mode using the keymaps created before.
libmodal.mode.enter('FOO', fooModeKeymaps, true)
