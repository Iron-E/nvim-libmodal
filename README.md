# nvim-libmodal

This is a rewrite of [vim-libmodal](https://github.com/Iron-E/vim-libmodal) using Neovim's Lua API. This project aims to be cross-compatable with `vim-libmodal`— with a few notable exceptions (see the [FAQ](#FAQ)).

## Requirements

* Neovim 0.7+.
* `vim-libmodal` is _not_ installed.

## Installation

You can use [packer.nvim](https://github.com/wbthomason/packer.nvim) (or any package manager) to install this plugin. The below example is for `packer.nvim`:

```lua
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/opt/packer.nvim'

if not vim.loop.fs_stat(vim.fn.glob(install_path)) then
	os.execute('git clone https://github.com/wbthomason/packer.nvim '..install_path)
end

vim.api.nvim_command 'packadd packer.nvim'

return require('packer').startup {function(use)
	use {'wbthomason/packer.nvim', opt=true}
	use 'Iron-E/nvim-libmodal'
	-- use {'Username/mode-plugin', wants='nvim-libmodal'}
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

You can add `libmodal` modes to your status line by using [`feline.nvim`](https://github.com/famiu/feline.nvim) or [`galaxyline.nvim`](https://github.com/glepnir/galaxyline.nvim) or . You can find my configuration for `feline.nvim` [here](https://gitlab.com/Iron_E/dotfiles/-/blob/master/.config/nvim/lua/plugin/feline.lua#L148-L164) and `galaxyline.nvim` [here](https://gitlab.com/Iron_E/dotfiles/-/blob/edf3e1c9779bbc81002832bb03ec875dc86cc16b/.config/nvim/lua/plugin/galaxyline.lua#L140-163)— both of which leverage `nvim-libmodal`'s in the statusbar.

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
