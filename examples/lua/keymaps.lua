local libmodal = require 'libmodal'

-- a function which will split the window both horizontally and vertically
local function split_twice()
	vim.api.nvim_command 'split'
	vim.api.nvim_command 'vsplit'
end

-- register keymaps for splitting windows and then closing windows
local fooModeKeymaps =
{
	h = 'norm h',
	j = 'norm j',
	k = 'norm k',
	l = 'norm l',

	G = function(self)
		local count = self.count:get()
		vim.api.nvim_command('norm! ' .. count .. 'G')
	end,

	d = 'delete',
	e = 'edit foo',
	o = 'norm o',
	p = 'bp',

	x = libmodal.mode.map.fn(vim.notify, 'hello'),

	zf = libmodal.mode.map.fn(vim.cmd.split),
	zfc = 'q',
	zff = split_twice,
	zfo = 'vsplit',
}

-- show that events work as expected
local id = vim.api.nvim_create_autocmd(
	{ 'CursorMoved', 'CursorMovedI', 'TextChanged', 'TextChangedI', 'TextChangedP', 'TextChangedT' },
	{ callback = function(ev) vim.notify(vim.inspect(ev)) end }
)

-- enter the mode using the keymaps
libmodal.mode.enter('FOO', fooModeKeymaps)

-- remove setup
vim.api.nvim_del_autocmd(id)
