local libmodal = require('libmodal')
local api = vim.api
local commandList = {'new', 'close', 'last'}

function barMode()
	local uinput = vim.api.nvim_get_var('barModeInput')
	if uinput == 'new' then
		api.nvim_command('tabnew')
	elseif uinput == 'close' then
		api.nvim_command('tabclose')
	elseif uinput == 'last' then
		api.nvim_command('tablast')
	end
end

libmodal.prompt.enter('BAR', barMode, commandList)
