--[[
	/*
	 * IMPORTS
	 */
--]]

local api = vim.api
local go = vim.go

--[[
	/*
	 * MODULE
	 */
--]]

local Popup = require('libmodal/src/classes').new(
	'libmodal-popup',
	{config = {
		anchor    = 'SW',
		col       = go.columns - 1,
		focusable = false,
		height    = 1,
		relative  = 'editor',
		row       = go.lines - go.cmdheight - 1,
		style     = 'minimal',
		width     = 1
	}}
)

----------------------------
--[[ SUMMARY:
	* Check if `window` is non-`nil` and is valid.
]]
--[[ PARAMS:
	* `window` => the window number.
]]
--[[ RETURNS:
	* `true` => `window` is non-`nil` and is valid
	* `false` => otherwise
]]
----------------------------
local function valid(window)
	return window and api.nvim_win_is_valid(window)
end

--[[
	/*
	 * META `Popup`
	 */
--]]

local _metaPopup = require('libmodal/src/classes').new(Popup.TYPE)

-------------------------------------
--[[ SUMMARY:
	* Close `self.window`
	* The `self` is inert after calling this.
]]
--[[ PARAMS:
	* `keep_buffer` => whether or not to keep `self.buffer`.
]]
-------------------------------------
function _metaPopup:close(keepBuffer)
	if valid(self.window) then
		api.nvim_win_close(self.window, false)
	end

	self.window = nil

	if not keepBuffer then
		self.buffer = nil
		self._inputChars = nil
	end
end

--------------------------
--[[ SUMMARY:
	* Open the popup.
	* If the popup was already open, close it and re-open it.
]]
--------------------------
function _metaPopup:open(config)
	if not config then config = Popup.config end

	if valid(self.window) then
		config = vim.tbl_extend('keep', config, api.nvim_win_get_config(self.window))
		self:close(true)
	end

	self.window = api.nvim_open_win(self.buffer, false, config)
end

---------------------------------------
--[[ SUMMARY:
	* Update `buffer` with the latest user `inputBytes`.
]]
--[[ PARAMS:
	* `inputBytes` => the charaters to fill the popup with.
]]
---------------------------------------
function _metaPopup:refresh(inputBytes)
	local inputBytesLen = #inputBytes

	-- The user simply typed one more character onto the last one.
	if inputBytesLen == #self._inputChars + 1 then
		self._inputChars[inputBytesLen] = string.char(inputBytes[inputBytesLen])
	elseif inputBytesLen == 1 then -- the user's typing was reset by a parser.
		self._inputChars = {string.char(inputBytes[1])}
	else -- other tries to optimize this procedure fell through, so do it the hard way.
		local chars = {}
		for i, byte in ipairs(inputBytes) do
			chars[i] = string.char(byte)
		end
		self._inputChars = chars
	end

	api.nvim_buf_set_lines(self.buffer, 0, 1, true, {
		table.concat(self._inputChars)
	})

	if not valid(self.window) or api.nvim_win_get_tabpage(self.window) ~= api.nvim_get_current_tabpage() then
		self:open()
	end

	api.nvim_win_set_width(self.window, #self._inputChars)
end

--[[
	/*
	 * CLASS `Popup`
	 */
--]]

--------------------
--[[ SUMMARY:
	* Create a new popup window.
]]
--[[ RETURNS:
	* A new popup window.
]]
--------------------
function Popup.new(config)
	local buf = api.nvim_create_buf(false, true)

	local self = setmetatable(
		{
			buffer = buf,
			_inputChars = {},
		},
		_metaPopup
	)

	self:open(config)

	return self
end

--[[
	/*
	 * PUBLICIZE `Popup`
	 */
--]]

return Popup
