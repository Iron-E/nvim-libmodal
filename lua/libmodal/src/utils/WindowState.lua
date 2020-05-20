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

--------------------------
--[[ SUMMARY:
	* Create a table representing the size of the current window.
]]
--[[ RETURNS:
	* The new `WindowState`.
]]
--------------------------
function WindowState.new()
	local winState = {
		['height'] = api.nvim_get_option(height),
		['width'] = api.nvim_get_option(width),
	}

	---------------------------
	--[[ SUMMARY
		* Restore the state of `self`.
	]]
	---------------------------
	function winState:restore()
		api.nvim_set_option(height, self['height'])
		api.nvim_set_option(width, self['width'])
	end

	return winState
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return WindowState
