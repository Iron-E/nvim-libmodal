local libmodal = require 'libmodal'

local k = vim.keycode or function(s)
	return vim.api.nvim_replace_termcodes(s, true, true, true)
end

-- register key commands and what they do
local fooModeKeymaps =
{
	[k '<Esc>'] = 'echom "You cant exit using escape."',
	q = 'let g:fooModeExit = 1', -- exits all instances of this mode
	x = function(self)
		self:exit() -- exits this instance of the mode
	end,
}

-- tell the mode not to exit automatically
vim.g.fooModeExit = false

-- enter the mode using the keymaps created before
libmodal.mode.enter('FOO', fooModeKeymaps, true)
