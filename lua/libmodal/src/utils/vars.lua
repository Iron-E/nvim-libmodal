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
		name = function(modeName)
			return modeName .. varName
		end
	}
end

-------------------------------
--[[ SUMMARY:
	* Retrieve a variable value.
]]

--[[ PARAMS:
	* `var` => the `vars.*` table to retrieve the value of.
	* `modeName` => the mode name this value is being retrieved for.
]]
-------------------------------
function vars.get(var, modeName)
	return api.nvim_get_vars(var.name(modeName))
end

--[[
	/*
	 * VARS
	 */
--]]
new('combos'  , 'ModeCombos')
new('input'   , 'ModeInput')
new('timeout' , 'ModeTimeout')

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]
return vars
