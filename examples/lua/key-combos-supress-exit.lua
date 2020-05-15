local libmodal = require('libmodal')
local fooModeCombos = {
	[''] = 'echom "You cant exit using escape."',
	['q'] = 'let g:fooModeExit = 1'
}

vim.api.nvim_set_var('fooModeExit', 0)
libmodal.mode.enter('FOO', fooModeCombos, true)
