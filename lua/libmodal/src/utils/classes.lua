--- @class libmodal.utils.classes
local classes =
{
	--- define a metatable.
	--- @param template? table the default value
	--- @return table class
	new = function(template)
		-- set self to `template`, or `{}` if nil.
		local self = template or {}

		-- set `__index`.
		self.__index = self

		return self
	end,
}

return classes
