--[[
	/*
	 * IMPORTS
	 */
--]]
local api = vim.api

--[[
	/*
	 * MODULE
	 */
--]]
local WindowState = {}

--[[
	/*
	 * STRUCT `WindowState`
	 */
--]]

function WindowState.new()
	return {
		['height'] = api.nvim_get_option('winheight'),
		['width'] = api.nvim_get_option('winwidth')
	}
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]
return WindowState
