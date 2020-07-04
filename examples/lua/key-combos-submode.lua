local libmodal = require('libmodal')

local fooModeRecurse = 0
local fooModeCombos  = {
	['z'] = 'lua FooMode()'
}

function FooMode()
	fooModeRecurse = fooModeRecurse + 1
	libmodal.mode.enter('FOO' .. fooModeRecurse, fooModeCombos)
	fooModeRecurse = fooModeRecurse - 1
end

FooMode()
