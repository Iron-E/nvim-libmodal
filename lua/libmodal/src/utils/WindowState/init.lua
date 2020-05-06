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

local height = 'winheight'
local width = 'winwidth'

--[[
	/*
	 * CLASS `WindowState`
	 */
--]]

function WindowState.new()
	local winState = {
		['height'] = api.nvim_get_option(height),
		['width'] = api.nvim_get_option(width),
	}

	function winState:restore()
		api.nvim_set_option(height, self['height'])
		api.nvim_set_option(width, self['width'])
	end

	return winState
end

function WindowState.restore(state)
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]
return WindowState
