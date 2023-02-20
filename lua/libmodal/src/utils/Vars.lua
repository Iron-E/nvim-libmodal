--- @class libmodal.utils.Vars
--- @field private mode_name string the highlight group to use when printing `str`
--- @field private var_name string the highlight group to use when printing `str`
local Vars = require('libmodal/src/utils/classes').new(nil)

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

	local function no_spaces(str_with_spaces, first_letter_modifier)
		local split_str = vim.split(string.gsub(str_with_spaces, vim.pesc '_', vim.pesc ' '), ' ')

		local function camel_case(str, func)
			return func(string.sub(str, 0, 1) or '') .. string.lower(string.sub(str, 2) or '')
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

--- @param val unknown set `vim.g[self:name()])` equal to this value
function Vars:set(val)
	vim.g[self:name()] = val
end

return Vars
