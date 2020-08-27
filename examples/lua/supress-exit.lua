-- Imports
local api = vim.api
local libmodal = require('libmodal')

-- Function which is called whenever the user presses a button
local function fooMode()
	-- Append to the input history, the latest button press.
	local userInput = string.char(
		-- The input is a character number.
		api.nvim_get_var('fooModeInput')
	)

	if userInput == '' then
		api.nvim_command("echom 'You cant leave using <Esc>.'")
	elseif userInput == 'q' then
		-- If the user presses 'q', libmodal will exit the mode.
		api.nvim_set_var('fooModeExit', true)
	end
end

-- Tell libmodal not to exit the mode immediately.
api.nvim_set_var('fooModeExit', 0)

-- Enter the mode.
libmodal.mode.enter('FOO', fooMode, true)
