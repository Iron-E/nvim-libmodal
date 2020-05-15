local libmodal = require('libmodal')
local fooModeCombos = {
	['zf'] = 'split',
	['zfo'] = 'vsplit',
	['zfc'] = 'tabnew'
}

libmodal.mode.enter('FOO', fooModeCombos)
