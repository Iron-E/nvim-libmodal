-- Imports
local libmodal = require 'libmodal'

-- Keep track of the user's input history manually.
local input_history = {}

-- Clear the input history if it grows too long for our usage.
function input_history:clear(index_to_check)
	if #self >= index_to_check then
		for i, _ in ipairs(self) do
			self[i] = nil
		end
	end
end

-- This is the function that will be called whenever the user presses a button.
local function foo_mode()
	-- Append to the input history, the latest button press.
	input_history[#input_history + 1] = string.char(
		-- The input is a character number.
		vim.g.fooModeInput
	)

	-- Custom logic to test for each character index to see if it matches the 'zfo' mapping.
	local index = 1
	if input_history[1] == 'z' then
		if input_history[2] == 'f' then
			if input_history[3] == 'o' then
				vim.api.nvim_command "echom 'It works!'"
			else index = 3
			end
		else index = 2
		end
	end

	input_history:clear(index)
end

-- Enter the mode to begin the demo.
libmodal.mode.enter('FOO', foo_mode)
