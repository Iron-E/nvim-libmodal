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

local Popup = {
	['TYPE'] = 'libmodal-popup',
	['config'] = {
		['anchor']    = 'SW',
		['col']       = api.nvim_get_option('columns') - 1,
		['focusable'] = false,
		['height']    = 1,
		['relative']  = 'editor',
		['row']       = api.nvim_get_option('lines')
		                - api.nvim_get_option('cmdheight')
		                - 1,
		['style']     = 'minimal',
		['width']     = 25
	}
}

--[[
	/*
	 * META `Popup`
	 */
--]]

local _metaPopup = require('libmodal/src/classes').new(Popup.TYPE)

---------------------------
--[[ SUMMARY:
	* Close `self.window`
	* The `self` is inert after calling this.
]]
---------------------------
function _metaPopup:close()
	api.nvim_win_close(self.window, false)

	self.buffer     = nil
	self._inputChars = nil
	self.window      = nil
end

---------------------------------------
--[[ SUMMARY:
	* Update `buffer` with the latest user `inputBytes`.
]]
---------------------------------------
function _metaPopup:refresh(inputBytes)
	local inputBytesLen = #inputBytes
	local inputChars    = self._inputChars

	-- The user simply typed one more character onto the last one.
	if inputBytesLen == #inputChars + 1 then
		inputChars[inputBytesLen] = string.char(inputBytes[inputBytesLen])
	elseif inputBytesLen == 1 then
		inputChars = {string.char(inputBytes[1])}
	else -- other tries to optimize this procedure fellthrough, so do it the hard way.
		local chars = {}
		for i, byte in ipairs(inputBytes) do
			chars[i] = string.char(byte)
		end
		self._inputChars = chars
	end

	api.nvim_buf_set_lines(
		self.buffer, 0, 1, true,
		{table.concat(self._inputChars)}
	)
end

--[[
	/*
	 * CLASS `Popup`
	 */
--]]

function Popup.new()
	local buf = api.nvim_create_buf(false, true)

	return setmetatable(
		{
			['buffer']     = buf,
			['_inputChars'] = {},
			['window']      = api.nvim_call_function(
				'nvim_open_win', {buf, false, Popup.config}
			)
		},
		_metaPopup
	)
end

--[[
	/*
	 * PUBLICIZE `Popup`
	 */
--]]

return Popup
