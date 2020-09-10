-- Import
local libmodal = require('libmodal')

-- Define commands through a dictionary.
local commands = {
	['new']   = 'tabnew',
	['close'] = 'tabclose',
	['last']  = 'tablast',
	['exit'] = libmodal.utils.api.mode_exit
}

-- Begin the prompt.
libmodal.prompt.enter('FOO', commands)
