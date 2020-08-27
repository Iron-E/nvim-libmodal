-- Imports
local libmodal = require('libmodal')

-- Register key combos for splitting windows and then closing windows
local fooModeCombos = {
	['zf'] = 'split',
	['zfo'] = 'vsplit',
	['zfc'] = 'q'
}

-- Enter the mode using the key combos.
libmodal.mode.enter('FOO', fooModeCombos)
