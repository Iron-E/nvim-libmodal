--[[
	/*
	 * MODULE `Stack`
	 */
--]]

local Stack = {TYPE = 'libmodal-stack'}

--[[
	/*
	 * META `Stack`
	 */
--]]

local _metaStack = require('libmodal/src/classes').new(Stack.TYPE)

_metaStack._len = 0

--------------------------------
--[[ SUMMARY:
	* Get the foremost value in `self`.
]]
--[[
	* The foremost value in `self`.
]]
--------------------------------
function _metaStack:peek()
	return self._top
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
	local previousLen = self._len

	if previousLen < 1 then return nil
	end

	-- Store the previous top of the stack.
	local previousTop = self._top

	-- Remove the previous top of the stack.
	self[previousLen] = nil

	-- Get the new length of the stack
	local newLen = previousLen - 1

	-- Update the values of the stack.
	if newLen < 1 then -- the stack is empty
		self._len = nil
		self._top = nil
	else -- there is still something in the stack
		self._len = newLen
		self._top = self[newLen]
	end

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
	-- create placeholder so new values are not put into the table until operations have succeeded.
	local newLen = self._len + 1

	-- Push to the stack
	self[newLen] = value

	-- update stack values
	self._len  = newLen
	self._top = value
end

--[[
	/*
	 * CLASS `Stack`
	 */
--]]

function Stack.new()
	return setmetatable({}, _metaStack)
end

--[[
	/*
	 * PUBLICIZE `Stack`
	 */
--]]

return Stack
