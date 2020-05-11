local libmodal = require('libmodal')
local commands = {
	['new'] = 'tabnew',
	['close'] = 'tabclose',
	['last'] = 'tablast'
}

libmodal.prompt.enter('BAR', commands)
