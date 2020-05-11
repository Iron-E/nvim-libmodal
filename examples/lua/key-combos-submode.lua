local libmodal = require('libmodal')
local barModeRecurse = 0
local barModeCombos = {
	['z'] = 'lua barMode()'
}

function barMode()
	barModeRecurse = barModeRecurse + 1
	libmodal.mode.enter('BAR' .. barModeRecurse, barModeCombos)
	barModeRecurse = barModeRecurse - 1
end

barMode()
