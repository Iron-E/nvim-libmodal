# nvim-libmodal

This is a rewrite of [vim-libmodal](https://github.com/Iron-E/vim-libmodal) using Neovim's Lua API. This project aims to be cross-compatable with `vim-libmodal`— with a few notable exceptions (see the [FAQ](#FAQ)).

## Installation

Either use `packadd` or any package manager. I recommend using [lazy.nvim](https://github.com/folke/lazy.nvim).

### Requirements

* Neovim 0.7+.
* `vim-libmodal` is _not_ installed.

### Examples

#### lazy.nvim

```lua
{'Iron-E/nvim-libmodal', lazy = true},
```

#### packer.nvim

You can use [packer.nvim](https://github.com/wbthomason/packer.nvim) to install this plugin. The below example is for `packer.nvim`:

```lua
return require('packer').startup {function(use)
	use 'Iron-E/nvim-libmodal'
end}
```

## Usage

The following plugins have been constructed using `nvim-libmodal`:

* [`nvim-bufmode`](https://github.com/Iron-E/nvim-bufmode)
* [`nvim-marktext`](https://github.com/Iron-E/nvim-marktext)
* [`nvim-tabmode`](https://github.com/Iron-E/nvim-tabmode)

The following samples have been constructed using `nvim-libmodal`:

* [`mode-codedoc`](https://gitlab.com/Iron_E/dotfiles/-/blob/master/.config/nvim/lua/mode-codedoc.lua)
* [The Official Lua Examples](https://github.com/Iron-E/nvim-libmodal/tree/master/examples/lua)
* [The Official Vimscript Examples](https://github.com/Iron-E/nvim-libmodal/tree/master/examples)

See [docs](./doc) for more information.

### Statusline

You can add `libmodal` modes to your status line. Here are a few examples of how to integrate with existing plugins.

#### feline.nvim

See my configuration for `feline.nvim` [here](https://gitlab.com/Iron_E/dotfiles/-/blob/78e17b41cadd1660f8d3506ffce093437eb80aae/.config/nvim/lua/plugin/feline.lua#L134-160)

#### galaxyline.nvim

See my configuration for `galaxyline.nvim` [here](https://gitlab.com/Iron_E/dotfiles/-/blob/edf3e1c9779bbc81002832bb03ec875dc86cc16b/.config/nvim/lua/plugin/galaxyline.lua#L140-163).

#### lualine.nvim

<details>
	<summary>An example config</summary>
	<pre lang = "lua">
-- Defined in https://github.com/Iron-E/nvim-highlite
local BLUE         = '#7766ff'
local CYAN         = '#33dbc3'
local GREEN        = '#22ff22'
local GREEN_LIGHT  = '#99ff99'
local ICE          = '#95c5ff'
local ORANGE       = '#ff8900'
local ORANGE_LIGHT = '#f0af00'
local PINK         = '#ffa6ff'
local PINK_LIGHT   = '#ffb7b7'
local PURPLE       = '#cf55f0'
local PURPLE_LIGHT = '#af60af'
local RED          = '#ee4a59'
local RED_DARK     = '#a80000'
local RED_LIGHT    = '#ff4090'
local TAN          = '#f4c069'
local TEAL         = '#60afff'
local TURQOISE     = '#2bff99'
local YELLOW       = '#f0df33'
 
local MODES =
{ -- {{{
	['c']  = {'COMMAND-LINE',     RED},
	['ce'] = {'NORMAL EX',        RED_DARK},
	['cv'] = {'EX',               RED_LIGHT},
	['i']  = {'INSERT',           GREEN},
	['ic'] = {'INS-COMPLETE',     GREEN_LIGHT},
	['n']  = {'NORMAL',           PURPLE_LIGHT},
	['no'] = {'OPERATOR-PENDING', PURPLE},
	['r']  = {'HIT-ENTER',        CYAN},
	['r?'] = {':CONFIRM',         CYAN},
	['rm'] = {'--MORE',           ICE},
	['R']  = {'REPLACE',          PINK},
	['Rv'] = {'VIRTUAL',          PINK_LIGHT},
	['s']  = {'SELECT',           TURQOISE},
	['S']  = {'SELECT',           TURQOISE},
	['␓'] = {'SELECT',            TURQOISE},
	['t']  = {'TERMINAL',         ORANGE},
	['v']  = {'VISUAL',           BLUE},
	['V']  = {'VISUAL LINE',      BLUE},
	['␖'] = {'VISUAL BLOCK',      BLUE},
	['!']  = {'SHELL',            YELLOW},
 
	-- libmodal
	['BUFFERS'] = TEAL,
	['TABLES']  = ORANGE_LIGHT,
	['TABS']    = TAN,
} -- }}}
 
local MODE_HL_GROUP = 'LualineViMode'
 
--[[/* FELINE CONFIG */]]
 
vim.api.nvim_create_autocmd('User', {
	callback = function()
		require('lualine').refresh {scope = 'window',  place = {'statusline'}}
	end,
	pattern = {'LibmodalModeEnterPre', 'LibmodalModeLeavePost'},
})
 
require('lualine').setup {sections = {lualine_a = {{
	function() -- auto change color according the vim mode
		local mode_color, mode_name
 
		if vim.g.libmodalActiveModeName then
			mode_name = vim.g.libmodalActiveModeName
			mode_color = MODES[mode_name]
		else
			local current_mode = MODES[vim.api.nvim_get_mode().mode]
 
			mode_name = current_mode[1]
			mode_color = current_mode[2]
		end
 
		vim.api.nvim_set_hl(0, MODE_HL_GROUP, {fg = mode_color, bold = true})
 
		return mode_name..' '
	end,
	icon = {'▊', align = 'left'},
	color = MODE_HL_GROUP,
	padding = 0,
}}}}
	</pre>
</details>

#### staline.nvim

<details>
	<summary>An example config</summary>
	<pre lang = "lua">
--[[/* CONSTANTS */]]
 
-- Defined in https://github.com/Iron-E/nvim-highlite
local BLUE         = '#7766ff'
local CYAN         = '#33dbc3'
local GREEN        = '#22ff22'
local GREEN_LIGHT  = '#99ff99'
local ICE          = '#95c5ff'
local ORANGE       = '#ff8900'
local ORANGE_LIGHT = '#f0af00'
local PINK         = '#ffa6ff'
local PINK_LIGHT   = '#ffb7b7'
local PURPLE       = '#cf55f0'
local PURPLE_LIGHT = '#af60af'
local RED          = '#ee4a59'
local RED_DARK     = '#a80000'
local RED_LIGHT    = '#ff4090'
local TAN          = '#f4c069'
local TEAL         = '#60afff'
local TURQOISE     = '#2bff99'
local YELLOW       = '#f0df33'
 
local MODES =
{ -- {{{
	['c']  = {'COMMAND-LINE', RED},
	['ce'] = {'NORMAL EX', RED_DARK},
	['cv'] = {'EX', RED_LIGHT},
	['i']  = {'INSERT', GREEN},
	['ic'] = {'INS-COMPLETE', GREEN_LIGHT},
	['n']  = {'NORMAL', PURPLE_LIGHT},
	['no'] = {'OPERATOR-PENDING', PURPLE},
	['r']  = {'HIT-ENTER', CYAN},
	['r?'] = {':CONFIRM', CYAN},
	['rm'] = {'--MORE', ICE},
	['R']  = {'REPLACE', PINK},
	['Rv'] = {'VIRTUAL', PINK_LIGHT},
	['s']  = {'SELECT', TURQOISE},
	['S']  = {'SELECT', TURQOISE},
	['␓'] = {'SELECT', TURQOISE},
	['t']  = {'TERMINAL', ORANGE},
	['v']  = {'VISUAL', BLUE},
	['V']  = {'VISUAL LINE', BLUE},
	['␖'] = {'VISUAL BLOCK', BLUE},
	['!']  = {'SHELL', YELLOW},
 
	-- libmodal
	['BUFFERS'] = TEAL,
	['TABLES']  = ORANGE_LIGHT,
	['TABS']    = TAN,
} -- }}}
 
local MODE_HL_GROUP = 'StalineViMode'
 
--[[/* FELINE CONFIG */]]
 
vim.api.nvim_set_hl(0, MODE_HL_GROUP, {})
require('staline').setup(
{
	mode_colors = {},
	mode_icons = {},
	sections = {left =
	{
		function()
			local mode_color, mode_name
 
			if vim.g.libmodalActiveModeName then
				mode_name = vim.g.libmodalActiveModeName
				mode_color = MODES[mode_name]
			else
				local current_mode = MODES[vim.api.nvim_get_mode().mode]
 
				mode_name = current_mode[1]
				mode_color = current_mode[2]
			end
 
			vim.api.nvim_set_hl(0, MODE_HL_GROUP, {bold = true, fg = mode_color})
			return {MODE_HL_GROUP, mode_name}
		end,
	}},
})
	</pre>
</details>

## FAQ

### nvim-libmodal vs. vim-libmodal

The following is a list of expressions that work in `nvim-libmodal` but not `vim-libmodal`:

* `require 'libmodal'` in Lua.
	* `vim-libmodal` does not support interacting with it through Lua, you must use the Vimscript interface.

The following is a list of expressions that work in `vim-libmodal` but not `nvim-libmodal`:

* `call libmodal#Enter('FOO', funcref('bar'), baz)` in Vimscript.
	* Lua does not support passing `funcref`s from Vimscript. Try using the Lua interface instead.
* `call libmodal#Prompt('FOO', funcref('bar'), baz)` in Vimscript.
	* Lua does not support passing `funcref`s from Vimscript. Try using the Lua interface instead.
