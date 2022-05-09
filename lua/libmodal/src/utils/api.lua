local globals = require 'libmodal/src/globals'
local Indicator = require 'libmodal/src/utils/Indicator'

local api = {}

--- echo a list of `Indicator`s with their associated highlighting.
--- @param indicators libmodal.utils.Indicator|table<libmodal.utils.Indicator> the indicators to echo
function api.hi_echo(indicators)
	if indicators.hl then -- wrap the single indicator in a table to form a list of indicators
		indicators = {indicators}
	end

	api.redraw()

	for _, indicator in ipairs(indicators) do
		vim.api.nvim_command('echohl ' .. indicator.hl .. " | echon '" .. indicator.str .. "'")
	end

	vim.api.nvim_command 'echohl None'
end

--- send a character to exit a mode.
--- @param exit_char string the character used to exit the mode, or ESCAPE if none was provided.
function api.mode_exit(exit_char)
	-- if there was no provided `exit_char`, or it is a character code.
	if not exit_char or type(exit_char) == globals.TYPE_NUM then
		-- translate the character code or default to escape.
		exit_char = string.char(exit_char or globals.ESC_NR)
	end

	-- exit the prompt by sending an escape key.
	vim.api.nvim_feedkeys(exit_char, 'nt', false)
end

--- run the `mode` command to refresh the screen.
function api.redraw()
	vim.api.nvim_command 'mode'
end

return api
