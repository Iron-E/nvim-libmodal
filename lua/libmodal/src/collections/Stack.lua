--[[
	/*
	 * MODULE `Stack`
	 */
--]]

local Stack = {}

--[[
	/*
	 * META `Stack`
	 */
--]]

local _metaStack = {}
_metaStack.__index = _metaStack

_metaStack._len = 0
_metaStack._top = nil

--------------------------------
--[[ SUMMARY:
	* Get the foremost value in `self`.
]]
--[[
	* The foremost value in `self`.
]]
--------------------------------
function _metaStack:peek()
	return top
end

-------------------------
--[[ SUMMARY:
	* Remove the foremost value in `self` and return it.
]]
--[[ RETURNS:
	* The foremost value in `self`.
]]
-------------------------
function _metaStack:pop()
	if len < 1 then return nil
	end

	-- Store the previous top of the stack.
	local previousTop = self._top

	-- Remove the previous top of the stack.
	self[_len] = nil

	-- Update the values of the stack.
	self._len = self._len - 1
	self._top = self[_len]

	-- Return the previous top of the stack.
	return previousTop
end

-------------------------------
--[[ SUMMARY:
	* Push some `value` onto `self`.
]]
--[[ PARAMS:
	* `value` => the value to append to `self`.
]]
-------------------------------
function _metaStack:push(value)
	self._len  = self._len + 1
	self[_len] = value
end

--[[
	/*
	 * CLASS `Stack`
	 */
--]]

function Stack.new()
	local self = {}
	setmetatable(self, _metaStack)

	return self
end
