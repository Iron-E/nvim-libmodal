--- @class libmodal.globals
--- @field ESC_NR integer the key-code for the escape character.
--- @field VIM_FALSE integer the value of Vimscript's `v:false`
--- @field VIM_TRUE integer the value of Vimscript's `v:true`
local globals =
{
	ESC_NR = vim.api.nvim_replace_termcodes('<Esc>', true, true, true):byte(),
	VIM_FALSE = 0,
	VIM_TRUE  = 1,
}

--- assert some value is either `false` or `v:false`.
--- @param val boolean|integer
--- @return boolean
function globals.is_false(val)
	return val == false or val == globals.VIM_FALSE
end

--- assert some value is either `true` or `v:true`.
--- @param val boolean|integer
--- @return boolean
function globals.is_true(val)
	return val == true or val == globals.VIM_TRUE
end

return globals
