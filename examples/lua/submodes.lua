local libmodal = require('libmodal')
local fooModeRecurse = 0

function fooMode()
	local userInput = string.char(vim.api.nvim_get_var(
		'foo' .. tostring(fooModeRecurse) .. 'ModeInput'
	))

	if userInput == 'z' then
		fooModeRecurse = fooModeRecurse + 1
		enter()
		fooModeRecurse = fooModeRecurse - 1
	end
end

function enter()
	libmodal.mode.enter('FOO' .. fooModeRecurse, fooMode)
end

enter()
