local api = vim.api
local libmodal = require('libmodal')

local function fooMode()
	local userInput = string.char(
		api.nvim_get_var('fooModeInput')
	)

	if userInput == '' then
		api.nvim_command("echom 'You cant leave using <Esc>.'")
	elseif userInput == 'q' then
		api.nvim_set_var('fooModeExit', true)
	end
end

api.nvim_set_var('fooModeExit', 0)
libmodal.mode.enter('FOO', fooMode, true)
