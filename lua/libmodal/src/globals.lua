--- @class libmodal.globals
--- @field ESC_NR number the key-code for the escape character.
--- @field TYPE_FUNC string the string which is returned by `type(function() end)` (or any function)
--- @field TYPE_NUM string the string which is returned by `type(0)` (or any number)
--- @field TYPE_STR string the string which is returned by `type ''` (or any string)
--- @field TYPE_TBL string the string which is returned by `type {}` (or any table)
--- @field VIM_FALSE number the value of Vimscript's `v:false`
--- @field VIM_TRUE number the value of Vimscript's `v:true`
local globals =
{
	ESC_NR = 27,
	TYPE_FUNC = type(function() end),
	TYPE_NUM  = type(0),
	TYPE_STR = type '',
	TYPE_TBL = type {},
	VIM_FALSE = 0,
	VIM_TRUE  = 1,
}

--- assert some value is either `false` or `v:false`.
--- @param val boolean|number
--- @return boolean
function globals.is_false(val)
	return val == false or val == globals.VIM_FALSE
end

--- assert some value is either `true` or `v:true`.
--- @param val boolean|number
--- @return boolean
function globals.is_true(val)
	return val == true or val == globals.VIM_TRUE
end

return globals
