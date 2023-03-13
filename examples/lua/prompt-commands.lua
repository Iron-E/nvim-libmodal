local libmodal = require 'libmodal'

-- define commands through a dictionary
local commands =
{
	new   = 'tabnew',
	close = 'tabclose',
	last  = 'tablast',
	exit = 'let g:fooModeExit = v:true',
}

-- begin the prompt
vim.g.fooModeExit = false
libmodal.prompt.enter('FOO', commands)
