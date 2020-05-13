local libmodal = require('libmodal')
local barModeRecurse = 0

function barMode()
	local userInput = string.char(vim.api.nvim_get_var(
		'bar' .. tostring(barModeRecurse) .. 'ModeInput'
	))

	if userInput == 'z' then
		barModeRecurse = barModeRecurse + 1
		enter()
		barModeRecurse = barModeRecurse - 1
	end
end

function enter()
	libmodal.mode.enter('BAR' .. barModeRecurse, barMode)
end

enter()
