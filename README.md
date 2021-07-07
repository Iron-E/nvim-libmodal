# About

This is a rewrite of [vim-libmodal][libmodal] using Neovim's Lua API.

Unfortunately, during `vim-libmodal`'s development several problems with Vimscript became apparent. Because of this, I have decided to rewrite it using Lua. This project aims to be cross-compatable with `vim-libmodal` version 2.`X`.`Y`, with the only alterations being _additions_ to the source code that have been made under the 2.x.y revision number.

> `funcref()` cannot be used in `libmodal#Enter` or `libmodal#Prompt`, so `nvim-libmodal` is _mostly_ compatable, but not completely.
>
> * See |libmodal-usage| for more details.

Note that cross-compatability does not mean that `vim-libmodal` and `nvim-libmodal` can be installed at the same time— as a matter of fact, they are developed specifically to replace each other for specific platforms. If you use Vim, use `vim-libmodal`. If you use Neovim, use `nvim-libmodal`. If you are a plugin creator, all code that works for `vim-libmodal` will work with `nvim-libmodal`, but the reverse is not true.

# Requirements

* Neovim 0.4+.
	* For compatability with `vim-libmodal`, Neovim 0.5+.
	* For statusbar integration, Neovim 0.5+.
* `vim-libmodal` is _not_ installed.

[libmodal]: https://github.com/Iron-E/vim-libmodal

# Usage

The following plugins have been constructed using `nvim-libmodal`:

* [`nvim-tabmode`](https://github.com/Iron-E/nvim-tabmode)
* [`nvim-typora`](https://github.com/Iron-E/nvim-typora)

The following samples have been constructed using `nvim-libmodal`:

* [`mode-codedoc`](https://gitlab.com/Iron_E/dotfiles/-/blob/master/.config/nvim/lua/mode-codedoc.lua)
* [`mode-fugidiff`](https://gitlab.com/Iron_E/dotfiles/-/blob/master/.config/nvim/lua/mode-fugidiff.lua)
* [The Official Lua Examples](https://github.com/Iron-E/nvim-libmodal/tree/master/examples/lua)
* [The Official Vimscript Examples](https://github.com/Iron-E/nvim-libmodal/tree/master/examples)

See [vim-libmodal][libmodal] and the [docs](./doc) for more information.

## Statusline

You can add `libmodal` modes to your status line by using [galaxyline.nvim](https://github.com/glepnir/galaxyline.nvim.git). Here is an example configuration:

```lua
local _COLORS =
{
	black  = {'#202020', 0,   'black'},
	red    = {'#ee4a59', 196, 'red'},
	orange = {'#ff8900', 208, 'darkyellow'},
	yellow = {'#f0df33', 220, 'yellow'},
	green  = {'#77ff00', 72, 'green'},
	blue   = {'#7090ff', 63, 'darkblue'},
	purple = {'#cf55f0', 129, 'magenta'},
}

-- Statusline color
_COLORS.bar = {middle=_COLORS.gray_dark, side=_COLORS.black}

-- Text color
_COLORS.text = _COLORS.gray_light

-- Table which gets hex values from _COLORS.
local _HEX_COLORS = setmetatable(
	{bar = setmetatable({}, {__index = function(_, key) return _COLORS.bar[key] and _COLORS.bar[key][1] or nil end})},
	{__index = function(_, key) local color = _COLORS[key] return color and color[1] or nil end}
)

local _MODES =
{
	c  = {'COMMAND-LINE',      _COLORS.red},
	ce = {'NORMAL EX',         _COLORS.red},
	cv = {'EX',                _COLORS.red},
	i  = {'INSERT',            _COLORS.green},
	ic = {'INS-COMPLETE',      _COLORS.green},
	n  = {'NORMAL',            _COLORS.purple},
	no = {'OPERATOR-PENDING',  _COLORS.purple},
	r  = {'HIT-ENTER',         _COLORS.blue},
	['r?'] = {':CONFIRM',          _COLORS.blue},
	rm = {'--MORE',            _COLORS.blue},
	R  = {'REPLACE',           _COLORS.red},
	Rv = {'VIRTUAL',           _COLORS.red},
	s  = {'SELECT',            _COLORS.blue},
	S  = {'SELECT',            _COLORS.blue},
	t  = {'TERMINAL',          _COLORS.orange},
	v  = {'VISUAL',            _COLORS.blue},
	V  = {'VISUAL LINE',       _COLORS.blue},
	['!']  = {'SHELL',             _COLORS.yellow},

	-- libmodal
	TABS    = _COLORS.tan,
	BUFFERS = _COLORS.teal,
	TABLES  = _COLORS.orange_light,
}

require('galaxyline').section.left =
{
	{ViMode = {
		provider = function() -- auto change color according the vim mode
			local mode_color = nil
			local mode_name = nil

			if vim.g.libmodalActiveModeName then
				mode_name = vim.g.libmodalActiveModeName
				mode_color = _MODES[mode_name]
			else
				local current_mode = _MODES[vim.fn.mode(true)]

				mode_name = current_mode[1]
				mode_color = current_mode[2]
			end

			-- If you have Iron-E/nvim-highlite, use this step.
			-- If not, just manually highlight it with vim.cmd()
			require('highlite').highlight('GalaxyViMode', {fg=mode_color, style='bold'})

			return '▊ '..mode_name..' '
		end,
		highlight = {_HEX_COLORS.bar.side, _HEX_COLORS.bar.side},
		separator = _SEPARATORS.right,
		separator_highlight = {_HEX_COLORS.bar.side, get_file_icon_color}
	}}
}
```
