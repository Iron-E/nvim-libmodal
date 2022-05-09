--- @class libmodal.utils
--- @field private completions libmodal.utils.api
--- @field private classes libmodal.utils.classes
--- @field private Indicator libmodal.utils.Indicator
--- @field private Help libmodal.utils.Help
--- @field private Popup libmodal.utils.Popup
--- @field private Vars libmodal.utils.Vars
return
{
	api = require 'libmodal/src/utils/api',
	classes = require 'libmodal/src/utils/classes',
	Indicator = require 'libmodal/src/utils/Indicator',
	Help = require 'libmodal/src/utils/Help',

	--- `vim.notify` with a `msg` some `error` which has a `vim.v.throwpoint` and `vim.v.exception`.
	--- @param msg string
	--- @param error string
	notify_error = function(msg, error)
		vim.notify(
			msg .. ': ' .. vim.v.throwpoint .. '\n' .. vim.v.exception .. '\n' .. error,
			vim.log.levels.ERROR,
			{title = 'nvim-libmodal'}
		)
	end,

	Popup = require 'libmodal/src/utils/Popup',
	Vars  = require 'libmodal/src/utils/Vars',
}
