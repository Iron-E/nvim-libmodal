--- @class libmodal.utils
--- @field api libmodal.utils.api
--- @field classes libmodal.utils.classes
--- @field Indicator libmodal.utils.Indicator
--- @field Help libmodal.utils.Help
--- @field Popup libmodal.utils.Popup
--- @field Vars libmodal.utils.Vars
local utils =
{
	api = require 'libmodal/src/utils/api',
	classes = require 'libmodal/src/utils/classes',
	Indicator = require 'libmodal/src/utils/Indicator',
	Help = require 'libmodal/src/utils/Help',
	Popup = require 'libmodal/src/utils/Popup',
	Vars  = require 'libmodal/src/utils/Vars',
}

--- `vim.notify` with a `msg` some `error` which has a `vim.v.throwpoint` and `vim.v.exception`.
--- @param msg string
--- @param err string
function utils.notify_error(msg, err)
	vim.notify(
		msg .. ': ' .. vim.v.throwpoint .. '\n' .. vim.v.exception .. '\n' .. err,
		vim.log.levels.ERROR,
		{title = 'nvim-libmodal'}
	)
end

return utils
