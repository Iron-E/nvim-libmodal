local libmodal = require('libmodal')
local barModeCombos = {
	[''] = 'echom "You cant exit using escape."',
	['q'] = 'let g:barModeExit = 1'
}

vim.api.nvim_set_var('barModeExit', 0)
libmodal.mode.enter('BAR', barModeCombos, true)
