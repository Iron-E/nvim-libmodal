--- @class libmodal
local libmodal = setmetatable({}, {
	__index = function(tbl, key)
		if key ~= 'Layer' then
			return rawget(tbl, key)
		else
			if vim.deprecate then
				vim.deprecate('`libmodal.Layer`', '`libmodal.layer`', '4.0.0', 'nvim-libmodal')
			else
				vim.notify_once(
					'`libmodal.Layer` is deprecated in favor of `libmodal.layer`. It will work FOR NOW, but uncapitalize that `L` please :)',
					vim.log.levels.WARN,
					{title = 'nvim-libmodal'}
				)
			end

			return rawget(tbl, 'layer')
		end
	end,
})

libmodal.layer = {}

--- enter a new layer.
--- @param keymap table the keymaps (e.g. `{n = {gg = {rhs = 'G', silent = true}}}`)
--- @param exit_char? string a character which can be used to exit the layer from normal mode.
--- @return fun()|nil exit a function to exit the layer, or `nil` if `exit_char` is passed
function libmodal.layer.enter(keymap, exit_char)
	local layer = require('libmodal.Layer').new(keymap)
	layer:enter()

	if exit_char then
		layer:map('n', exit_char, function() layer:exit() end, {})
	else
		return function() layer:exit() end
	end
end

--- create a new layer.
--- @param keymap table the keymaps (e.g. `{n = {gg = {rhs = 'G', silent = true}}}`)
--- @return libmodal.Layer
function libmodal.layer.new(keymap)
		return require('libmodal.Layer').new(keymap)
end

libmodal.mode = {}

--- enter a mode.
--- @param name string the name of the mode.
--- @param instruction fun()|string|table a Lua function, keymap dictionary, Vimscript command.
function libmodal.mode.enter(name, instruction, supress_exit)
	local mode = require('libmodal.Mode').new(name, instruction, supress_exit)
	mode:enter()
end

--- `enter` a mode using the arguments given, and do not return to the current mode.
--- @param ... unknown arguments to `libmodal.mode.enter`
--- @return fun(self: libmodal.Mode) switcher enters the mode
--- @see libmodal.mode.enter which this function takes the same arguments as
function libmodal.mode.switch(...)
	local args = { ... }
	return function(self)
		self:switch(unpack(args))
	end
end

libmodal.prompt = {}

--- enter a prompt.
--- @param name string the name of the prompt
--- @param instruction fun()|{[string]: fun()|string} what to do with user input
--- @param user_completions? string[] a list of possible inputs, provided by the user
function libmodal.prompt.enter(name, instruction, user_completions)
	require('libmodal.Prompt').new(name, instruction, user_completions):enter()
end

return libmodal
