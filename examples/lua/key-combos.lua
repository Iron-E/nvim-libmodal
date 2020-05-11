local libmodal = require('libmodal')
local barModeCombos = {
	['zf'] = 'split',
	['zfo'] = 'vsplit',
	['zfc'] = 'tabnew'
}

libmodal.mode.enter('BAR', barModeCombos)
