-- Imports
local cmd = vim.api.nvim_command
local libmodal = require 'libmodal'

-- A function which will split the window both horizontally and vertically.
local function _split_twice()
	cmd 'split'
	cmd 'vsplit'
end

-- Register key combos for splitting windows and then closing windows
local fooModeCombos = {
	zf = 'split',
	zfo = 'vsplit',
	zfc = 'q',
	zff = _split_twice
}

-- Enter the mode using the key combos.
libmodal.mode.enter('FOO', fooModeCombos)
