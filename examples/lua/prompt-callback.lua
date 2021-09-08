-- Imports
local libmodal = require 'libmodal'

-- The list of commands. Providing this will allow for autocomplete.
local commandList = {'new', 'close', 'last'}

-- The function which will be called whenever the user enters a command.
function FooMode()
	local userInput = vim.g.fooModeInput
	if userInput == 'new' then
		vim.api.nvim_command 'tabnew'
	elseif userInput == 'close' then
		vim.api.nvim_command 'tabclose'
	elseif userInput == 'last' then
		vim.api.nvim_command 'tablast'
	end
end

-- Enter the prompt.
libmodal.prompt.enter('FOO', FooMode, commandList)
