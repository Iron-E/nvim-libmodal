-- Imports
local libmodal = require('libmodal')

-- Register key commands and what they do.
local fooModeCombos = {
	[''] = 'echom "You cant exit using escape."',
	['q'] = 'let g:fooModeExit = 1'
}

-- Tell the mode not to exit automatically.
vim.api.nvim_set_var('fooModeExit', 0)

-- Enter the mode using the key combos created before.
libmodal.mode.enter('FOO', fooModeCombos, true)
