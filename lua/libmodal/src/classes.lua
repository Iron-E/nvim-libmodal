local classes = {}

--------------------------
--[[ SUMMARY:
	* Define a class-metatable.
]]
--------------------------
function classes.new(base)
	base.__index = base
	return base
end

return classes
