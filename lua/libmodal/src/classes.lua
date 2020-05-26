--[[
	/*
	 * MODULE
	 */
--]]

local classes = {}

--------------------------
--[[ SUMMARY:
	* Define a class-metatable.
]]
--[[
	* `name` => the name of the class.
	* `base` => the base class to use (`{}` by default).
]]
--------------------------------
function classes.new(name, ...)
	-- set self to `base`, or `{}` if nil.
	local self = unpack({...}) or {}

	-- set `__index`.
	if not self.__index then
		self.__index = self
	end

	-- set `__type`.
	self.__type  = name

	return self
end

------------------------
function classes.type(v)
	return v.__type or type(v)
end

--[[
	/*
	 * PUBLICIZE `classes`
	 */
--]]

return classes
