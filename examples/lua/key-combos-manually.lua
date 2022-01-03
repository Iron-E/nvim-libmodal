-- Imports
local libmodal = require 'libmodal'

-- Keep track of the user's input history manually.
local _inputHistory = {}

-- Clear the input history if it grows too long for our usage.
function _inputHistory:clear(indexToCheck)
	if #self >= indexToCheck then
		for i, _ in ipairs(self) do
			self[i] = nil
		end
	end
end

-- This is the function that will be called whenever the user presses a button.
local function fooMode()
	-- Append to the input history, the latest button press.
	_inputHistory[#_inputHistory + 1] = string.char(
		-- The input is a character number.
		vim.g.fooModeInput
	)

	-- Custom logic to test for each character index to see if it matches the 'zfo' mapping.
	local index = 1
	if _inputHistory[1] == 'z' then
		if _inputHistory[2] == 'f' then
			if _inputHistory[3] == 'o' then
				vim.api.nvim_command "echom 'It works!'"
			else index = 3
			end
		else index = 2
		end
	end

	_inputHistory:clear(index)
end

-- Enter the mode to begin the demo.
libmodal.mode.enter('FOO', fooMode)
