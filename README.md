# About

This is a rewrite of [vim-libmodal][libmodal] using Neovim's Lua API.

Unfortunately, during `vim-libmodal`'s development several problems with Vimscript became apparent. Because of this, I have decided to rewrite it using Lua. This project aims to be cross-compatable with `vim-libmodal` version 2.`X`.`Y`, with the only alterations being _additions_ to the source code that have been made under the 2.x.y revision number.

> __NOTE:__ There cannot be cross-compatability until Neovim 0.5.

Note that cross-compatability does not mean that `vim-libmodal` and `nvim-libmodal` can be installed at the same time— as a matter of fact, they are developed specifically to replace each other for specific platforms. If you use Vim, use `vim-libmodal`. If you use Neovim, use `nvim-libmodal`. If you are a plugin creator, all code that works for `vim-libmodal` will work with `nvim-libmodal`, but the reverse is not true.

See [vim-libmodal][libmodal] and the [docs](./doc) for more information.

# Requirements

* Neovim 0.4+
	* Eventually 0.5 will be required.
* `vim-libmodal` is _not_ installed.

[libmodal]: https://github.com/Iron-E/vim-libmodal
