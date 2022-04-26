local libmodal = require 'libmodal'

-- a function which will split the window both horizontally and vertically
local function split_twice()
	vim.api.nvim_command 'split'
	vim.api.nvim_command 'vsplit'
end

-- register keymaps for splitting windows and then closing windows
local fooModeKeymaps =
{
	zf = 'split',
	zfo = 'vsplit',
	zfc = 'q',
	zff = split_twice
}

-- enter the mode using the keymaps
libmodal.mode.enter('FOO', fooModeKeymaps)
