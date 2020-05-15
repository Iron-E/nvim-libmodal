local libmodal = require('libmodal')
local api = vim.api
local commandList = {'new', 'close', 'last'}

function fooMode()
	local userInput = vim.api.nvim_get_var('fooModeInput')
	if userInput == 'new' then
		api.nvim_command('tabnew')
	elseif userInput == 'close' then
		api.nvim_command('tabclose')
	elseif userInput == 'last' then
		api.nvim_command('tablast')
	end
end

libmodal.prompt.enter('FOO', fooMode, commandList)
