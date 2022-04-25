local globals = require 'libmodal/src/globals'
local Indicator = require 'libmodal/src/utils/Indicator'

--[[/* MODULE */]]

local api = {}

--- Send a character to exit a mode.
--- @param exit_char string the character used to exit the mode, or ESCAPE if none was provided.
function api.mode_exit(exit_char)
	-- If there was no provided `exit_char`, or it is a character code.
	if not exit_char or type(exit_char) == globals.TYPE_NUM then
		-- Translate the character code or default to escape.
		exit_char = string.char(exit_char or globals.ESC_NR)
	end

	-- Exit the prompt by sending an escape key.
	vim.api.nvim_feedkeys(exit_char, 'nt', false)
end

--- Make vim ring the visual/audio bell, if it is enabled.
function api.nvim_bell()
	vim.api.nvim_command('normal '..string.char(27)) -- escape char
end

--- Run the `mode` command to refresh the screen.
function api.nvim_redraw()
	vim.api.nvim_command 'mode'
end

--- Echo a list of `Indicator`s with their associated highlighting.
--- @param indicators libmodal.utils.Indicator|table<libmodal.utils.Indicator> the indicators to echo
function api.nvim_lecho(indicators)
	if indicators.hl then -- wrap the single indicator in a table to form a list of indicators
		indicators = {indicators}
	end

	api.nvim_redraw()

	for _, indicator in ipairs(indicators) do
		vim.api.nvim_command('echohl ' .. indicator.hl .. " | echon '" .. indicator.str .. "'")
	end

	vim.api.nvim_command 'echohl None'
end

--- Show an error.
--- @param title string a succint category of error
--- @param msg string a descriptive reason for the error
function api.nvim_show_err(title, msg)
	api.nvim_lecho {Indicator.new('Title', tostring(title)..'\n'), Indicator.new('Error', tostring(msg))}
	vim.fn.getchar()
end

return api
