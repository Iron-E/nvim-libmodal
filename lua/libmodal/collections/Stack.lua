--- @class libmodal.collections.Stack<T>
--- @field private [number] T
local Stack = require('libmodal.utils.classes').new()

--- @generic T
--- @return libmodal.collections.Stack<T>
function Stack.new()
	return setmetatable({}, Stack)
end

--- @generic T
--- @return T top the foremost value of the stack
function Stack:peek()
	return self[#self]
end

--- remove the foremost value from the stack and return it.
--- @generic T
--- @return T top the foremost value of the stack
function Stack:pop()
	return table.remove(self)
end

--- push some `value` on to the stack.
--- @generic T
--- @param value T the value to push onto the stack.
function Stack:push(value)
	-- push to the stack
	table.insert(self, value)
end

return Stack
