--- @class libmodal.utils.Vars
--- @field private mode_name string the highlight group to use when printing `str`
--- @field private value? unknown the local value of the variable
--- @field private var_name string the highlight group to use when printing `str`
local Vars = require('libmodal.utils.classes').new()

--- create a new set of variables
--- @param var_name string the name of the key used to refer to this variable in `Vars`.
--- @param mode_name string the name of the mode
--- @param default_global? unknown the default global value
--- @return libmodal.utils.Vars
function Vars.new(var_name, mode_name, default_global)
	local self = setmetatable({}, Vars)

	--- @param str_with_spaces string
	--- @param first_letter_modifier fun(s: string): string
	local function no_spaces(str_with_spaces, first_letter_modifier)
		local split_str = vim.split(str_with_spaces:gsub(vim.pesc '_', vim.pesc ' '), ' ')

		--- @param str string
		--- @param func fun(s: string): string
		local function camel_case(str, func)
			return func(str:sub(0, 1) or '') .. (str:sub(2) or ''):lower()
		end

		split_str[1] = camel_case(split_str[1], first_letter_modifier)

		for i = 2, #split_str do split_str[i] =
			camel_case(split_str[i], string.upper)
		end

		return table.concat(split_str)
	end

	self.mode_name = no_spaces(mode_name, string.lower)
	self.var_name  = 'Mode' .. no_spaces(var_name, string.upper)
	self.value = nil

	if default_global ~= nil and self:get_global() == nil then
		self:set_global(default_global)
	end

	return self
end

--- @generic T
--- @return T value the local value if it exists, or the global value
function Vars:get()
	local local_value = self:get_local()
	if local_value == nil then
		return self:get_global()
	end

	return local_value
end

--- @generic T
--- @return T global_value the global value
function Vars:get_local()
	return self.value
end

--- @generic T
--- @return T global_value the global value
function Vars:get_global()
	return vim.g[self:name()]
end

--- @return string name the global Neovim setting
function Vars:name()
	return self.mode_name .. self.var_name
end

--- NOTE: the local value is only set if not `nil`, for backwards compatibility purposes.
---       local values did not always exist, and since `get` prefers local values, it may
---       too-eagerly shadow the global variable.
--- @param val unknown set local value if it exists, or the global value
--- @return nil
function Vars:set(val)
	if self:get_local() == nil then
		self:set_global(val)
	else
		self:set_local(val)
	end
end

--- @param val unknown set the local value equal to this
--- @return nil
function Vars:set_local(val)
	self.value = val
end

--- @param val unknown set the global value equal to this
--- @return nil
function Vars:set_global(val)
	if val == nil then
		vim.api.nvim_del_var(self:name()) -- because `nvim_set_var('foo', nil)` actually sets 'foo' to `vim.NIL`
	else
		vim.api.nvim_set_var(self:name(), val)
	end
end

return Vars
