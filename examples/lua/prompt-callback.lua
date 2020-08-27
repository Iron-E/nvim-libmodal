-- Imports
local libmodal = require('libmodal')
local api = vim.api

-- The list of commands. Providing this will allow for autocomplete.
local commandList = {'new', 'close', 'last'}

-- The function which will be called whenever the user enters a command.
function FooMode()
	local userInput = vim.api.nvim_get_var('fooModeInput')
	if userInput == 'new' then
		api.nvim_command('tabnew')
	elseif userInput == 'close' then
		api.nvim_command('tabclose')
	elseif userInput == 'last' then
		api.nvim_command('tablast')
	end
end

-- Enter the prompt.
libmodal.prompt.enter('FOO', FooMode, commandList)
