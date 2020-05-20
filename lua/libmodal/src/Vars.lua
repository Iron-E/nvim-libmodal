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
	 * META `_metaVars`
	 */
--]]

local _metaVars = {}

-- Instances of variables pertaining to a certain mode.
_metaVars.varName = nil

-------------------------
--[[ SUMMARY:
	* Get the name of `modeName`s global setting.
]]
--[[ PARAMS:
	* `modeName` => the name of the mode.
]]
-------------------------
function _metaVars:name(modeName)
	return string.lower(modeName) .. self._varName
end

------------------------------------
--[[ SUMMARY:
	* Retrieve a variable value.
]]
--[[ PARAMS:
	* `modeName` => the mode name this value is being retrieved for.
]]
------------------------------------
function _metaVars:nvimGet(modeName)
	return api.nvim_get_var(self:name(modeName))
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
function _metaVars:nvimSet(modeName, val)
	api.nvim_set_var(self:name(modeName), val)
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
function Vars.new(keyName)
	self = {}
	setmetatable(self, _metaVars)
	self.__index = self

	self._varName = 'Mode' .. string.upper(
		string.sub(keyName, 0, 1)
	) .. string.sub(keyName, 2)

	return self
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return Vars
