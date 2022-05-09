local VIM_FALSE = 0
local VIM_TRUE  = 1

return {
	--- the key-code for the escape character.
	ESC_NR = 27,

	--- the string which is returned by `type(function() end)` (or any function)
	TYPE_FUNC = type(function() end),

	--- the string which is returned by `type(0)` (or any number)
	TYPE_NUM  = type(0),

	--- the string which is returned by `type ''` (or any string)
	TYPE_STR = type '',

	--- the string which is returned by `type {}` (or any table)
	TYPE_TBL = type {},

	--- the value of Vimscript's `v:false`
	VIM_FALSE = VIM_FALSE,

	--- the value of Vimscript's `v:true`
	VIM_TRUE  = VIM_TRUE,

	--- assert some value is either `false` or `v:false`.
	--- @param val boolean|number
	--- @return boolean
	is_false = function(val)
		return val == false or val == VIM_FALSE
	end,

	--- assert some value is either `true` or `v:true`.
	--- @param val boolean|number
	--- @return boolean
	is_true = function(val)
		return val == true or val == VIM_TRUE
	end
}
