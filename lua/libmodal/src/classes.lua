return {
	-------------------------
	--[[ SUMMARY:
		* Define a class-metatable.
	]]
	--[[
		* `name` => the name of the class.
		* `base` => the base class to use (`{}` by default).
	]]
	-------------------------
	new = function(name, ...)
		-- set self to `base`, or `{}` if nil.
		local self = unpack({...}) or {}

		-- set `__index`.
		if not self.__index then
			self.__index = self
		end

		-- set `__type`.
		self.__type  = name

		return self
	end,

	------------------
	--[[ SUMMARY:
		* Get the type of some value `v`, if it has one.
	]]
	--[[ PARAMS:
		* `v` => the value to get the type of.
	]]
	------------------
	type = function(v)
		return v.__type or type(v)
	end
}
