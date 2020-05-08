local libmodal = require('libmodal')

local barModeRecurse = 0

local barModeCombos = {
	['z'] = 'BarModeEnter',
}

function barMode()
	barModeRecurse = barModeRecurse + 1
	libmodal.mode.enter('BAR' .. barModeRecurse, barModeCombos)
	barModeRecurse = barModeRecurse - 1
end

vim.api.nvim_command('command! BarModeEnter lua barMode()')
barMode()
