--[[/* IMPORTS */]]

local fn = vim.fn
local globals = require('libmodal/src/globals')
local HighlightSegment = require('libmodal/src/Indicator/HighlightSegment')
local vim_api = vim.api

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
	vim_api.nvim_feedkeys(exit_char, 'nt', false)
end

--- Make vim ring the visual/audio bell, if it is enabled.
function api.nvim_bell()
	vim_api.nvim_command('normal '..string.char(27)) -- escape char
end

--- Gets one character of user input, as a number.
function api.nvim_input()
	return fn.getchar()
end

--------------------------
--[[ SUMMARY:
	* Run `mode` to refresh the screen.
	* The function was not named `nvim_mode` because that would be really confusing given the name of this plugin.
]]
--------------------------
function api.nvim_redraw()
	vim_api.nvim_command 'mode'
end

---------------------------------
--[[ SUMMARY:
	* Echo a table of {`hlgroup`, `str`} tables.
	* Meant to be read as "nvim list echo".
]]
--[[ PARAMS:
	* `hlTables` => the tables to echo with highlights.
]]
---------------------------------
local lecho_template = {
	[1] = "echohl ",
	[2] = nil,
	[3] = " | echon '",
	[4] = nil,
	[5] = "'"
}
function api.nvim_lecho(hlTables)
	api.nvim_redraw()
	for _, hlTable in ipairs(hlTables) do
		-- `:echohl` the hlgroup and then `:echon` the string
		lecho_template[2] = tostring(hlTable.hl)
		lecho_template[4] = tostring(hlTable.str)

		vim_api.nvim_command(table.concat(lecho_template))
	end
	vim_api.nvim_command 'echohl None'
end

--------------------------------------
--[[ SUMMARY:
	* Show a `title` error.
]]
--[[ PARAMS:
	* `title` => the title of the error.
	* `msg` => the message of the error.
]]
--------------------------------------
function api.nvim_show_err(title, msg)
	api.nvim_lecho({
		HighlightSegment.new('Title', tostring(title)..'\n'),
		HighlightSegment.new('Error', tostring(msg)),
	})
	fn.getchar()
end

return api
