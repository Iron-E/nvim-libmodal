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

local _TIMEOUT_GLOBAL_NAME = 'libmodalTimeouts'

local Vars = {
	[_TIMEOUT_GLOBAL_NAME] = api.nvim_get_var(_TIMEOUT_GLOBAL_NAME),
	['TYPE'] = 'libmodal-vars'
}

--[[
	/*
	 * META `_metaVars`
	 */
--]]

local _metaVars = require('libmodal/src/classes').new(Vars.TYPE)

---------------------------------
--[[ SUMMARY:
	* Get the name of `modeName`s global setting.
]]
--[[ PARAMS:
	* `modeName` => the name of the mode.
]]
---------------------------------
function _metaVars:name()
	return self._modeName .. self._varName
end

------------------------------------
--[[ SUMMARY:
	* Retrieve a variable value.
]]
--[[ PARAMS:
	* `modeName` => the mode name this value is being retrieved for.
]]
------------------------------------
function _metaVars:nvimGet()
	return api.nvim_get_var(self:name())
end

-----------------------------------------
--[[ SUMMARY:
	* Set a variable value.
]]
--[[ PARAMS:
	* `modeName` => the mode name this value is being retrieved for.
	* `val` => the value to set `self`'s Vimscript var to.
]]
-----------------------------------------
function _metaVars:nvimSet(val)
	api.nvim_set_var(self:name(), val)
end

--[[
	/*
	 * CLASS `VARS`
	 */
--]]

--------------------------
--[[ SUMMARY:
	* Create a new entry in `Vars`
]]
--[[ PARAMS:
	* `keyName` => the name of the key used to refer to this variable in `Vars`.
]]
--------------------------
function Vars.new(keyName, modeName)
	local self = setmetatable({}, _metaVars)

	local function noSpaces(strWithSpaces, firstLetterModifier)
		local splitStr = vim.split(
			string.gsub(strWithSpaces, vim.pesc('_'), vim.pesc(' ')),
			' '
		)

		local function camelCase(str, func)
			return func(string.sub(str, 0, 1) or '')
				.. string.lower(string.sub(str, 2) or '')
		end

		splitStr[1] = camelCase(splitStr[1], firstLetterModifier)

		for i = 2, #splitStr do splitStr[i] =
			camelCase(splitStr[i], string.upper)
		end

		return table.concat(splitStr)
	end

	self._modeName = noSpaces(modeName, string.lower)

	self._varName  = 'Mode' .. noSpaces(keyName, string.upper)

	return self
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return Vars
