local libmodal = require('libmodal')
local fooModeCombos = {
	['zf'] = 'split',
	['zfo'] = 'vsplit',
	['zfc'] = 'q'
}

libmodal.mode.enter('FOO', fooModeCombos)
