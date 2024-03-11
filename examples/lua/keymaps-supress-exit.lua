local libmodal = require 'libmodal'

local k = vim.keycode or function(s)
	return vim.api.nvim_replace_termcodes(s, true, true, true)
end

local barModeKeymaps = {
	p = function() vim.notify('Hello!') end,
}

-- register key commands and what they do
local fooModeKeymaps =
{
	[k '<Esc>'] = 'echom "You cant exit using escape."',
	q = 'let g:fooModeExit = 1', -- exits all instances of this mode
	x = function(self)
		self:exit() -- exits this instance of the mode
	end,
	y = function(self)
		self:switch('Bar', barModeKeymaps) -- enters Bar and then exits Foo when it is done
	end,
	z = libmodal.mode.switch('Bar', barModeKeymaps), -- the same as above, but more convenience
}

-- tell the mode not to exit automatically
vim.g.fooModeExit = false

-- enter the mode using the keymaps created before
libmodal.mode.enter('FOO', fooModeKeymaps, true)
