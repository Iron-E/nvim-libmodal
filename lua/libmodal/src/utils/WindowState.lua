--[[
	/*
	 * IMPORTS
	 */
--]]

local api = vim.api
local libmodal_api = require('libmodal/src/utils/api')

--[[
	/*
	 * MODULE
	 */
--]]

local WindowState = {['TYPE'] = 'libmodal-window-state'}

local height = 'winheight'
local width = 'winwidth'

--[[
	/*
	 * META `WindowState`
	 */
--]]

local _metaWindowState = require('libmodal/src/classes').new(WindowState.TYPE)

-----------------------------------
--[[ SUMMARY
	* Restore the state of `self`.
]]
-----------------------------------
function _metaWindowState:restore()
	api.nvim_set_option(height, self.height)
	api.nvim_set_option(width, self.width)
	libmodal_api.nvim_redraw()
end

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
	return setmetatable(
		{
			['height'] = api.nvim_get_option(height),
			['width']  = api.nvim_get_option(width),
		},
		_metaWindowState
	)
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return WindowState
