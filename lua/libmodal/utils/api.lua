local globals = require 'libmodal.globals'

--- @class libmodal.utils.api
local api = {}

--- send a character to exit a mode.
--- @param exit_char? number|string the character used to exit the mode, or ESCAPE if none was provided.
--- @return nil
function api.mode_exit(exit_char)
	-- if there was no provided `exit_char`, or it is a character code.
	if type(exit_char) == 'number' then
		-- translate the character code or default to escape.
		--- @diagnostic disable-next-line:param-type-mismatch we just checked `exit_char` == `number`
		exit_char = string.char(exit_char)
	elseif not exit_char then
		-- translate the character code or default to escape.
		exit_char = string.char(globals.ESC_NR)
	end

	-- exit the prompt by sending an escape key.
	vim.api.nvim_feedkeys(exit_char, 'nt', false)
end

--- run the `mode` command to refresh the screen.
--- @return nil
function api.redraw()
	vim.api.nvim_command 'mode'
end

--- @param termcodes string
--- @return string replaced
function api.replace_termcodes(termcodes)
	return vim.api.nvim_replace_termcodes(termcodes, true, true, true)
end

return api
