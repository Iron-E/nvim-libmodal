--- @class libmodal.utils.Popup
--- @field private buffer number the number of the window which this popup is rendered on.
--- @field private input_chars string[] the characters input by the user.
--- @field private window number the number of the window which this popup is rendered on.
local Popup = require('libmodal/src/utils/classes').new(nil)

--- @param window number
--- @return boolean `true` if the window is non-`nil` and `nvim_win_is_valid`
local function valid(window)
	return window and vim.api.nvim_win_is_valid(window)
end

---  Close `self.window`
---  The `self` is inert after calling this.
--- @param keep_buffer boolean `self.buffer` is passed to `nvim_buf_delete` unless `keep_buffer` is `false`
function Popup:close(keep_buffer)
	if valid(self.window) then
		vim.api.nvim_win_close(self.window, false)
	end

	self.window = nil

	if not keep_buffer then
		vim.api.nvim_buf_delete(self.buffer, {force = true})
		self.buffer = nil
		self.input_chars = nil
	end
end

--- attempt to open this popup. If the popup was already open, close it and re-open it.
function Popup:open(config)
	if not config then
		config =
		{
			anchor    = 'SW',
			col       = vim.go.columns - 1,
			focusable = false,
			height    = 1,
			relative  = 'editor',
			row       = vim.go.lines - vim.go.cmdheight - 1,
			style     = 'minimal',
			width     = 1
		}
	end

	if valid(self.window) then
		self:close(true)
	end

	self.window = vim.api.nvim_open_win(self.buffer, false, config)
end

--- display `input_bytes` in `self.buffer`
--- @param input_bytes number[] a list of character codes to display
function Popup:refresh(input_bytes)
	-- the user simply typed one more character onto the last one.
	if #input_bytes == #self.input_chars + 1 then
		self.input_chars[#input_bytes] = string.char(input_bytes[#input_bytes])
	elseif #input_bytes == 1 then -- the user's typing was reset by a parser.
		self.input_chars = {string.char(input_bytes[1])}
	else -- other tries to optimize this procedure fell through, so do it the hard way.
		self.input_chars = {}
		for i, byte in ipairs(input_bytes) do
			self.input_chars[i] = string.char(byte)
		end
	end

	vim.api.nvim_buf_set_lines(self.buffer, 0, 1, true, {table.concat(self.input_chars)})

	-- close and reopen the window if it was not already open.
	if not valid(self.window) or vim.api.nvim_win_get_tabpage(self.window) ~= vim.api.nvim_get_current_tabpage() then
		self:open()
	end

	vim.api.nvim_win_set_width(self.window, #self.input_chars)
end

return
{
	new = function(config)
		local self = setmetatable({buffer = vim.api.nvim_create_buf(false, true), input_chars = {}}, Popup)
		self:open(config)
		return self
	end
}
