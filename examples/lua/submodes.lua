local libmodal = require 'libmodal'

-- recurse counter
local foo_mode_recurse = 1

-- function which is called whenever the user presses a button
function FooMode()
	-- append to the input history, the latest button press
	local userInput = string.char(vim.g[
		-- the input is a character number
		'foo' .. tostring(foo_mode_recurse) .. 'ModeInput'
	])

	-- if the user pressed 'z', then increase the counter and recurse
	if userInput == 'z' then
		foo_mode_recurse = foo_mode_recurse + 1
		Enter()
		foo_mode_recurse = foo_mode_recurse - 1
	end
end

-- function to wrap around entering the mode so it can be recursively called
function Enter()
	libmodal.mode.enter('FOO' .. foo_mode_recurse, FooMode)
end

-- initially call the function to begin the demo
Enter()
