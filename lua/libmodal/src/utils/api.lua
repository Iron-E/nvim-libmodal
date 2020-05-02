--[[
	/*
	 * IMPORTS
	 */
--]]

local globals = require('libmodal/src/base/globals')

--[[
	/*
	 * MODULE
	 */
--]]

local api = vim.api

-----------------------------------
--[[ SUMMARY:
	* Check whether or not some variable exists.
]]

--[[
	* `scope` => The scope of the variable (i.e. `g`, `l`, etc.)
	* `var` => the variable to check for.
]]
-----------------------------------
function api.nvim_exists(scope, var)
	return api.nvim_eval("exists('" .. scope .. ":" .. var .. "')") ~= globals.VIM_FALSE
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return api
