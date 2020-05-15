local api = vim.api
local libmodal = require('libmodal')
local fooModeInputHistory = {}

local function clearHistory(indexToCheck)
	if #fooModeInputHistory >= indexToCheck then
		fooModeInputHistory = {}
	end
end

function fooMode()
	fooModeInputHistory[#fooModeInputHistory + 1] = string.char(
		api.nvim_get_var('fooModeInput')
	)

	local index = 1
	if fooModeInputHistory[1] == 'z' then
		if fooModeInputHistory[2] == 'f' then
			if fooModeInputHistory[3] == 'o' then
				api.nvim_command("echom 'It works!'")
			else index = 3 end
		else index = 2 end
	end

	clearHistory(index)
end

libmodal.mode.enter('FOO', fooMode)
