local libmodal = require('libmodal')

function barMode()
	local uinput = string.char(
		vim.api.nvim_get_var('barModeInput')
	)

	if uinput == '' then
		vim.api.nvim_command("echom 'You cant leave using <Esc>.'")
	elseif uinput == 'q' then
		vim.api.nvim_set_var('barModeExit', true)
	end
end

vim.api.nvim_set_var('barModeExit', 0)
libmodal.mode.enter('BAR', barMode, true)
