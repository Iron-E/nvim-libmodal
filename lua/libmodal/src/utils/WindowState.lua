--[[
	/*
	 * IMPORTS
	 */
--]]

local api = require('libmodal/src/utils/api')

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
	 * META `WindowState`
	 */
--]]

local _metaWindowState = {}
_metaWindowState.__index = _metaWindowState

-----------------------------------
--[[ SUMMARY
	* Restore the state of `self`.
]]
-----------------------------------
function _metaWindowState:restore()
	api.nvim_set_option(height, self.height)
	api.nvim_set_option(width, self.width)
	api.nvim_redraw()
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
