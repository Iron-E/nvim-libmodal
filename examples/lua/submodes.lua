-- Imports
local libmodal = require('libmodal')

-- Recurse counter
local fooModeRecurse = 1

-- Function which is called whenever the user presses a button
function FooMode()
	-- Append to the input history, the latest button press.
	local userInput = string.char(vim.api.nvim_get_var(
		-- The input is a character number.
		'foo' .. tostring(fooModeRecurse) .. 'ModeInput'
	))

	-- If the user pressed 'z', then increase the counter and recurse.
	if userInput == 'z' then
		fooModeRecurse = fooModeRecurse + 1
		Enter()
		fooModeRecurse = fooModeRecurse - 1
	end
end

-- Function to wrap around entering the mode so it can be recursively called.
function Enter()
	libmodal.mode.enter('FOO' .. fooModeRecurse, FooMode)
end

-- Initially call the function to begin the demo.
Enter()
