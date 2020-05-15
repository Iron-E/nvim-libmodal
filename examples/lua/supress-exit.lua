local libmodal = require('libmodal')

function fooMode()
	local userInput = string.char(
		vim.api.nvim_get_var('fooModeInput')
	)

	if userInput == '' then
		vim.api.nvim_command("echom 'You cant leave using <Esc>.'")
	elseif userInput == 'q' then
		vim.api.nvim_set_var('fooModeExit', true)
	end
end

vim.api.nvim_set_var('fooModeExit', 0)
libmodal.mode.enter('FOO', fooMode, true)
