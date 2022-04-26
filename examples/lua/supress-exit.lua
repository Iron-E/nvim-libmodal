local libmodal = require 'libmodal'

-- function which is called whenever the user presses a button
local function fooMode()
	-- append to the input history, the latest button press
	local userInput = string.char(
		-- the input is a character number
		vim.g.fooModeInput
	)

	if userInput == '' then
		vim.api.nvim_command "echom 'You cant leave using <Esc>.'"
	elseif userInput == 'q' then
		-- if the user presses 'q', libmodal will exit the mode
		vim.g.fooModeExit = true
	end
end

-- tell libmodal not to exit the mode immediately
vim.g.fooModeExit = false

-- enter the mode
libmodal.mode.enter('FOO', fooMode, true)
