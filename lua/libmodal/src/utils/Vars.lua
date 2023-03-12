--- @class libmodal.utils.Vars
--- @field private mode_name string the highlight group to use when printing `str`
--- @field private var_name string the highlight group to use when printing `str`
local Vars = require('libmodal.src.utils.classes').new()

--- @return unknown `vim.g[self:name()])`
function Vars:get()
	return vim.g[self:name()]
end

--- @return string name the global Neovim setting
function Vars:name()
	return self.mode_name .. self.var_name
end

--- create a new set of variables
--- @param var_name string the name of the key used to refer to this variable in `Vars`.
--- @param mode_name string the name of the mode
--- @return libmodal.utils.Vars
function Vars.new(var_name, mode_name)
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

	return self
end

--- @generic T
--- @param val T set `g:{self:name()})` equal to this value
--- @return nil
function Vars:set(val)
	vim.api.nvim_set_var(self:name(), val)
end

return Vars
