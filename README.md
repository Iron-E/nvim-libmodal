# About

This is a rewrite of [vim-libmodal][libmodal] using Neovim's Lua API.

Unfortunately, during `vim-libmodal`'s development several problems with Vimscript became apparent. Because of this, I have decided to rewrite it using Lua. This project aims to be cross-compatable with `vim-libmodal` version 2.`X`.`Y`, with the only alterations being _additions_ to the source code that have been made under the 2.x.y revision number.

> `funcref()` cannot be used in `libmodal#Enter` or `libmodal#Prompt`, so `nvim-libmodal` is _mostly_ compatable, but not completely.
>
> * See |libmodal-usage| for more details.

Note that cross-compatability does not mean that `vim-libmodal` and `nvim-libmodal` can be installed at the same time— as a matter of fact, they are developed specifically to replace each other for specific platforms. If you use Vim, use `vim-libmodal`. If you use Neovim, use `nvim-libmodal`. If you are a plugin creator, all code that works for `vim-libmodal` will work with `nvim-libmodal`, but the reverse is not true.

# Requirements

* Neovim 0.7+.
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

You can add `libmodal` modes to your status line by using [`feline.nvim`](https://github.com/famiu/feline.nvim) or [`galaxyline.nvim`](https://github.com/glepnir/galaxyline.nvim) or . You can find my configuration for `feline.nvim` [here](https://gitlab.com/Iron_E/dotfiles/-/blob/master/.config/nvim/lua/plugin/feline.lua#L127-154) and `galaxyline.nvim` [here](https://gitlab.com/Iron_E/dotfiles/-/blob/edf3e1c9779bbc81002832bb03ec875dc86cc16b/.config/nvim/lua/plugin/galaxyline.lua#L140-163)— both of which leverage `nvim-libmodal`'s in the statusbar.
