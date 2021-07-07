-- Imports
local libmodal = require 'libmodal'

-- Register key commands and what they do.
local fooModeCombos = {
	[''] = 'echom "You cant exit using escape."',
	q = 'let g:fooModeExit = 1'
}

-- Tell the mode not to exit automatically.
vim.g.fooModeExit = false

-- Enter the mode using the key combos created before.
libmodal.mode.enter('FOO', fooModeCombos, true)
