-- Import
local libmodal = require('libmodal')

-- A function, which when called, goes to the first tab.
local function _first()
	vim.api.nvim_command('tabfirst')
end

-- Define commands through a dictionary.
local commands = {
	['new']   = 'tabnew',
	['close'] = 'tabclose',
	['last']  = 'tablast',
	['first'] = _first
}

-- Begin the prompt.
libmodal.prompt.enter('FOO', commands)
