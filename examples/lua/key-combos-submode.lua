-- Imports
local libmodal = require('libmodal')

-- Recurse counter.
local fooModeRecurse = 0
-- Register 'z' as the map for recursing further (by calling the FooMode function again).
local fooModeCombos  = {
	z = 'lua FooMode()'
}

-- define the FooMode() function which is called whenever the user presses 'z'
function FooMode()
	fooModeRecurse = fooModeRecurse + 1
	libmodal.mode.enter('FOO' .. fooModeRecurse, fooModeCombos)
	fooModeRecurse = fooModeRecurse - 1
end

-- Define the character 'f' as the function we defined— but directly through lua, instead of vimL.
fooModeCombos['f'] = FooMode

-- Call FooMode() initially to begin the demo.
FooMode()
