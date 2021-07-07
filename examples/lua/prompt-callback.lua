-- Imports
local libmodal = require 'libmodal'
local cmd = vim.api.nvim_command

-- The list of commands. Providing this will allow for autocomplete.
local commandList = {'new', 'close', 'last'}

-- The function which will be called whenever the user enters a command.
function FooMode()
	local userInput = vim.g.fooModeInput
	if userInput == 'new' then
		cmd 'tabnew'
	elseif userInput == 'close' then
		cmd 'tabclose'
	elseif userInput == 'last' then
		cmd 'tablast'
	end
end

-- Enter the prompt.
libmodal.prompt.enter('FOO', FooMode, commandList)
