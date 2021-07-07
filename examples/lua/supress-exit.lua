-- Imports
local libmodal = require 'libmodal'

-- Function which is called whenever the user presses a button
local function fooMode()
	-- Append to the input history, the latest button press.
	local userInput = string.char(
		-- The input is a character number.
		vim.g.fooModeInput
	)

	if userInput == '' then
		vim.api.nvim_command "echom 'You cant leave using <Esc>.'"
	elseif userInput == 'q' then
		-- If the user presses 'q', libmodal will exit the mode.
		vim.g.fooModeExit = true
	end
end

-- Tell libmodal not to exit the mode immediately.
vim.g.fooModeExit = false

-- Enter the mode.
libmodal.mode.enter('FOO', fooMode, true)
