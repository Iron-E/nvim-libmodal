--[[
	/*
	 * IMPORTS
	 */
--]]

local api = vim.api

--[[
	/*
	 * MODULE
	 */
--]]

local vars = {
	combos          = {},
	input           = {},
	libmodalTimeout = api.nvim_get_var('libmodalTimeouts'),
	timeout         = {}
}

--[[
	/*
	 * HELPERS
	 */
--]]

-------------------------------
--[[ SUMMARY:
	* Create a new entry in `vars`
]]

--[[ PARAMS:
	* `keyName` => the name of the key used to refer to this variable in `vars`.
	* `varName` => the name of the variable as it is stored in vim.
]]
-------------------------------
local function new(keyName, varName)
	vars[keyName] = {
		-- Instances of variables pertaining to a certain mode.
		instances = {},

		-------------------------
		--[[ SUMMARY:
			* Get the name of `modeName`s global setting.
		]]
		--[[ PARAMS:
			* `modeName` => the name of the mode.
		]]
		-------------------------
		name = function(modeName)
			return modeName .. varName
		end,
	}
end

------------------------------------
--[[ SUMMARY:
	* Retrieve a variable value.
]]
--[[ PARAMS:
	* `var` => the `vars.*` table to retrieve the value of.
	* `modeName` => the mode name this value is being retrieved for.
]]
------------------------------------
function vars.nvim_get(var, modeName)
	return api.nvim_get_var(var.name(modeName))
end

function vars.nvim_set(var, modeName, val)
	api.nvim_set_var(var.name(modeName), val)
end

--[[
	/*
	 * VARS
	 */
--]]
new('combos'  , 'ModeCombos')
new('exit'    , 'ModeExit')
new('input'   , 'ModeInput')
new('timeout' , 'ModeTimeout')

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]
return vars
