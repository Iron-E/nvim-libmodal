local api = vim.api
local libmodal = require('libmodal')
local barModeInputHistory = {}

local function clearHistory(indexToCheck)
	if #barModeInputHistory >= indexToCheck then
		barModeInputHistory = {}
	end
end

function barMode()
	table.insert(barModeInputHistory, string.char(
		api.nvim_get_var('barModeInput')
	))

	local index = 1
	if barModeInputHistory[1] == 'z' then
		if barModeInputHistory[2] == 'f' then
			if barModeInputHistory[3] == 'o' then
				api.nvim_command("echom 'It works!'")
			else index = 3 end
		else index = 2 end
	end

	clearHistory(index)
end

libmodal.mode.enter('BAR', barMode)
