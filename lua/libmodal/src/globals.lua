--[[
	/*
	 * MODULE
	 */
--]]

local globals = {}

--[[
	/*
	 * TABLE `globals`
	 */
--]]

globals.DEFAULT_ERROR_TITLE = 'vim-libmodal error'
globals.ESC_NR = 27
globals.TYPE_FUNC = 'function'
globals.TYPE_NUM = 'number'
globals.TYPE_STR = 'string'
globals.TYPE_TBL = 'table'
globals.VIM_FALSE = 0
globals.VIM_TRUE  = 1

function globals.is_false(val)
	return val == false or val == globals.VIM_FALSE
end

function globals.is_true(val)
	return val == true or val == globals.VIM_TRUE
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return globals
