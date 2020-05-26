local _VIM_FALSE = 0
local _VIM_TRUE  = 1

return {
	['DEFAULT_ERROR_TITLE'] = 'vim-libmodal error',

	['ESC_NR'] = 27,

	['TYPE_FUNC'] = 'function',
	['TYPE_NUM']  = 'number',
	['TYPE_STR'] = 'string',
	['TYPE_TBL'] = 'table',

	['VIM_FALSE'] = _VIM_FALSE,
	['VIM_TRUE']  = _VIM_TRUE,

	is_false = function(val)
		return val == false or val == _VIM_FALSE
	end,

	is_true = function(val)
		return val == true  or val == _VIM_TRUE
	end
}

