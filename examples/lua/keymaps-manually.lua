local libmodal = require 'libmodal'

-- keep track of the user's input history manually
local input_history = {}

-- clear the input history if it grows too long for our usage
function input_history:clear(index_to_check)
	if #self >= index_to_check then
		for i, _ in ipairs(self) do
			self[i] = nil
		end
	end
end

-- this is the function that will be called whenever the user presses a button
local function foo_mode()
	-- append to the input history, the latest button press
	table.insert(input_history, string.char(
		-- the input is a character number
		vim.g.fooModeInput
	))

	-- custom logic to test for each character index to see if it matches the 'zfo' mapping
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

-- enter the mode to begin the demo
libmodal.mode.enter('FOO', foo_mode)
