--[[
	/*
	 * IMPORTS
	 */
--]]

local globals = require('libmodal/src/globals')
local api = vim.api

--[[
	/*
	 * MODULE
	 */
--]]

local Vars = {}

Vars.libmodalTimeouts = api.nvim_get_var('libmodalTimeouts')

--[[
	/*
	 * HELPERS
	 */
--]]

---------------------------
--[[ SUMMARY:
	* Create a new entry in `Vars`
]]
--[[ PARAMS:
	* `keyName` => the name of the key used to refer to this variable in `Vars`.
	* `varName` => the name of the variable as it is stored in vim.
]]
---------------------------
local function new(keyName)
	self = {}

	-- Instances of variables pertaining to a certain mode.
	local varName = 'Mode' .. string.upper(
		string.sub(keyName, 0, 1)
	) .. string.sub(keyName, 2)

	-------------------------
	--[[ SUMMARY:
		* Get the name of `modeName`s global setting.
	]]
	--[[ PARAMS:
		* `modeName` => the name of the mode.
	]]
	-------------------------
	name = function(modeName)
		return string.lower(modeName) .. self._varName
	end

	return self
end

------------------------------------
--[[ SUMMARY:
	* Retrieve a variable value.
]]
--[[ PARAMS:
	* `var` => the `Vars.*` table to retrieve the value of.
	* `modeName` => the mode name this value is being retrieved for.
]]
------------------------------------
function Vars.nvimGet(var, modeName)
	return api.nvim_get_var(var.name(modeName))
end

function Vars.nvimSet(var, modeName, val)
	api.nvim_set_var(var.name(modeName), val)
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return Vars
