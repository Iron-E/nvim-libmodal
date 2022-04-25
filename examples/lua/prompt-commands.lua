-- Import
local libmodal = require 'libmodal'

-- Define commands through a dictionary.
local commands =
{
	new   = 'tabnew',
	close = 'tabclose',
	last  = 'tablast',
	exit = 'let g:fooModeExit = v:true',
}

-- Begin the prompt.
libmodal.prompt.enter('FOO', commands)
