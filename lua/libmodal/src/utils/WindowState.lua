--[[/* IMPORTS */]]

local go = vim.go
local api = require('libmodal/src/utils/api')

--[[
	/*
	 * MODULE
	 */
--]]

local WindowState = {TYPE = 'libmodal-window-state'}

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
	go.winheight = self.height
	go.winwidth = self.width
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
			height = go.winheight,
			width  = go.winwidth,
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
