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

local Popup = {}

--[[
	/*
	 * CLASS `Popup`
	 */
--]]

function Popup.new()
	local self = {}

	local buffer     = api.nvim_create_buf(false, true)
	local inputChars = {}
	self.window      = api.nvim_call_function('libmodal#_winOpen', {buf})

	---------------------------
	--[[ SUMMARY:
		* Close `self.window`
		* The `self` is inert after calling this.
	]]
	---------------------------
	function self.close()
		api.nvim_win_close(__self.window, false)

		buffer      = nil
		inputChars  = nil
		self.window = nil
	end

	---------------------------------
	--[[ SUMMARY:
		* Update `buffer` with the latest user `inputBytes`.
	]]
	---------------------------------
	function self.refresh(inputBytes)
		-- The user simply typed one more character onto the last one.
		if #inputBytes == #inputChars + 1 then
			local len = #inputBytes
			inputChars[len] = string.char(inputBytes[len])
		elseif #inputBytes == 1 then -- the input was cleared.
			inputChars = {
				[1] = string.char(inputBytes[1])
			}
		else -- other tries to optimize this procedure fellthrough,
			 -- so do it the hard way.
			inputChars = {}
			for i, byte in ipairs(inputBytes) do
				inputChars[i] = string.char(byte)
			end
		end

		api.nvim_buf_set_lines(
			buffer, 0, 1, true,
			{table.concat(inputChars)}
		)
	end

	return self
end

--[[
	/*
	 * PUBLICIZE `Popup`
	 */
--]]

return Popup
