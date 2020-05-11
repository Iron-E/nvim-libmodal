local libmodal = require('libmodal')
local commandList = {'new', 'close', 'last'}

function barMode()
	local uinput = vim.api.nvim_get_var('tabModeInput')
	if uinput == 'new' then
		execute 'tabnew'
	elseif uinput == 'close' then
		execute 'tabclose'
	elseif uinput == 'last' then
		execute 'tablast'
	end
end

libmodal.prompt.enter('BAR', barMode, commandList)
