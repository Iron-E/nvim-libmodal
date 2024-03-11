local globals = require 'libmodal.globals'
local ParseTable = require 'libmodal.collections.ParseTable'
local utils = require 'libmodal.utils' --- @type libmodal.utils

--- @class libmodal.Mode
--- @field private flush_input_timer unknown
--- @field private global_exit libmodal.utils.Vars
--- @field private global_input libmodal.utils.Vars
--- @field private help? libmodal.utils.Help
--- @field private input_bytes? number[]
--- @field private instruction fun()|{[string]: fun()|string}
--- @field private local_exit boolean
--- @field private mappings libmodal.collections.ParseTable
--- @field private name string
--- @field private ns number the namespace where cursor highlights are drawn on
--- @field private popups libmodal.collections.Stack
--- @field private show_name fun()
--- @field private supress_exit boolean
--- @field private timeouts_enabled boolean
local Mode = utils.classes.new()

local HELP_CHAR = '?'
local TIMEOUT =
{
	CHAR = ' ',
	SEND = function(self) vim.api.nvim_feedkeys(self.CHAR, 'nt', false) end
}
TIMEOUT.CHAR_NUMBER = TIMEOUT.CHAR:byte()

--- execute the `instruction`.
--- @private
--- @param instruction fun(libmodal.Mode)|string a Lua function or Vimscript command.
--- @return nil
function Mode:execute_instruction(instruction)
	if type(instruction) == 'function' then
		instruction(self)
	else
		vim.api.nvim_command(instruction)
	end

	self:redraw_virtual_cursor()
end

--- check the user's input against the `self.instruction` mappings to see if there is anything to execute.
--- if there is nothing to execute, the user's input is rendered on the screen (as does Vim by default).
--- @private
--- @return nil
function Mode:check_input_for_mapping()
	-- stop any running timers
	self.flush_input_timer:stop()

	-- append the latest input to the locally stored input history.
	self.input_bytes[#self.input_bytes + 1] = self.global_input:get()

	-- get the command based on the users input.
	local cmd = self.mappings:get(self.input_bytes)

	-- get the type of the command.
	local command_type = type(cmd)

	-- if there was no matching command
	if not cmd then
		if #self.input_bytes < 2 and self.input_bytes[1] == HELP_CHAR:byte() then
			self.help:show()
		end

		self.input_bytes = {}
	elseif command_type == 'table' and globals.is_true(self.timeouts_enabled) then -- the command was a table, meaning that it MIGHT match.
		local timeout = vim.api.nvim_get_option_value('timeoutlen', {})
		self.flush_input_timer:start( -- start the timer
			timeout, 0, vim.schedule_wrap(function()
				-- send input to interrupt a blocking `getchar`
				TIMEOUT:SEND()
				-- if there is a command, execute it.
				if cmd[ParseTable.CR] then
					self:execute_instruction(cmd[ParseTable.CR])
				end
				-- clear input
				self.input_bytes = {}
				self.popups:peek():refresh(self.input_bytes)
			end)
		)
	else -- the command was an actual vim command.
		--- @diagnostic disable-next-line:param-type-mismatch already checked `cmd` != `table`
		self:execute_instruction(cmd)
		self.input_bytes = {}
	end

	self.popups:peek():refresh(self.input_bytes)
end

--- clears the virtual cursor from the screen
--- @private
function Mode:clear_virt_cursor()
	vim.api.nvim_buf_clear_namespace(0, self.ns, 0, -1);
end

--- enter this mode.
--- @return nil
function Mode:enter()
	-- intialize variables that are needed for each recurse of a function
	if type(self.instruction) == 'table' then
		-- initialize the input history variable.
		self.popups:push(utils.Popup.new())
	end

	self.local_exit = false

	--- HACK: https://github.com/neovim/neovim/issues/20793
	vim.api.nvim_command 'highlight Cursor blend=100'
	vim.schedule(function() vim.opt.guicursor:append { 'a:Cursor/lCursor' } end)
	self:render_virt_cursor()

	self.previous_mode_name = vim.g.libmodalActiveModeName
	vim.g.libmodalActiveModeName = self.name

	--[[ MODE LOOP. ]]
	local previous_mode = self.previous_mode_name or vim.api.nvim_get_mode().mode
	vim.api.nvim_exec_autocmds('ModeChanged', {pattern = previous_mode .. ':' .. self.name})

	local continue_mode = true
	while continue_mode do
		-- try (using pcall) to use the mode.
		local ok, mode_result = pcall(self.get_user_input, self)

		-- if there were errors, handle them.
		if not ok then
			--- @diagnostic disable-next-line:param-type-mismatch if `not ok` then `mode_result` is a string
			utils.notify_error('Error during nvim-libmodal mode', mode_result)
			continue_mode = false
		else
			continue_mode = mode_result
		end
	end

	self:tear_down()
	vim.api.nvim_exec_autocmds('ModeChanged', {pattern = self.name .. ':' .. previous_mode})
end

--- exit this instance of the mode.
--- WARN: does not interrupt the current mode to exit. It only flags that exit is desired for when control yields back
---       to the mode.
--- @return nil
function Mode:exit()
	self.local_exit = true
end

--- @private
--- @return boolean `true` if the mode's exit was flagged
function Mode:exit_flagged()
	return self.local_exit or globals.is_true(self.global_exit:get())
end

--- get input from the user.
--- @private
--- @return boolean more_input
function Mode:get_user_input()
	if self:exit_flagged() then
		return false
	end

	-- echo the indicator.
	self.show_name()

	-- capture input.
	local user_input = vim.fn.getchar()

	-- return if there was a timeout event.
	if user_input == TIMEOUT.CHAR_NUMBER then
		return true
	end

	-- set the global input variable to the new input.
	self.global_input:set(user_input)

	if not self.supress_exit and user_input == globals.ESC_NR then -- the user wants to exit.
		return false -- as in, "I don't want to continue."
	else -- the user wants to continue.

		--[[ The instruction type is determined every cycle, because the user may be assuming a more direct control
			over the instruction and it may change over the course of execution. ]]
		local instruction_type = type(self.instruction)

		if instruction_type == 'table' then -- the instruction was provided as a was a set of mappings.
			self:check_input_for_mapping()
		elseif instruction_type == 'string' then -- the instruction is the name of a Vimscript function.
			vim.fn[self.instruction]()
		else -- the instruction is a function.
			self.instruction()
		end
	end

	return true
end

--- clears and then renders the virtual cursor
--- @private
function Mode:redraw_virtual_cursor()
	self:clear_virt_cursor()
	self:render_virt_cursor()
end

--- render the virtual cursor using extmarks
--- @private
function Mode:render_virt_cursor()
	local line_nr, col_nr = unpack(vim.api.nvim_win_get_cursor(0))
	line_nr = line_nr - 1 -- win_get_cursor returns +1 for our purpose
	vim.highlight.range(0, self.ns, 'Cursor', { line_nr, col_nr }, { line_nr, col_nr + 1 }, {})
end

--- `enter` a `Mode` using the arguments given, and then flag the current mode to exit.
--- @param ... unknown arguments to `Mode.new`
--- @return nil
--- @see libmodal.Mode.enter which `...` shares the layout of
--- @see libmodal.Mode.exit
function Mode:switch(...)
	local mode = Mode.new(...)
	mode:enter()
	self:exit()
end

--- uninitialize variables from after exiting the mode.
--- @private
--- @return nil
function Mode:tear_down()
	if type(self.instruction) == 'table' then
		self.flush_input_timer:stop()
		self.input_bytes = nil

		self.popups:pop():close()
	end

	--- HACK: https://github.com/neovim/neovim/issues/20793
	self:clear_virt_cursor()
	vim.schedule(function() vim.opt.guicursor:remove { 'a:Cursor/lCursor' } end)
	vim.api.nvim_command 'highlight Cursor blend=0'

	if self.previous_mode_name and #vim.trim(self.previous_mode_name) < 1 then
		vim.g.libmodalActiveModeName = nil
	else
		vim.g.libmodalActiveModeName = self.previous_mode_name
	end

	utils.api.redraw()
end

--- create a new mode.
--- @private
--- @param name string the name of the mode.
--- @param instruction fun(libmodal.Mode)|string|table a Lua function, keymap dictionary, Vimscript command.
--- @param supress_exit? boolean
--- @return libmodal.Mode
function Mode.new(name, instruction, supress_exit)
	name = vim.trim(name)

	-- inherit the metatable.
	local self = setmetatable(
		{
			global_exit = utils.Vars.new('exit', name),
			global_input = utils.Vars.new('input', name),
			instruction = instruction,
			local_exit = false,
			name = name,
			ns = vim.api.nvim_create_namespace('libmodal' .. name),
		},
		Mode
	)

	self.show_name = vim.o.showmode and
		function()
			utils.api.redraw()
			vim.api.nvim_echo({{'-- ' .. name .. ' --', 'LibmodalPrompt'}}, false, {})
		end or
		utils.api.redraw

	-- define the exit flag
	self.supress_exit = supress_exit or false

	-- if the user provided keymaps
	if type(instruction) == 'table' then
		-- create a timer to perform actions with.
		self.flush_input_timer = vim.loop.new_timer()

		-- determine if a default `Help` should be created.
		if not self.instruction[HELP_CHAR] then
			self.help = utils.Help.new(instruction, 'KEY MAP')
		end

		self.input_bytes = {}

		-- build the parse tree.
		self.mappings = ParseTable.new(instruction)

		-- create a table for mode-specific data.
		self.popups = require('libmodal.collections.Stack').new()

		-- create a variable for whether or not timeouts are enabled.
		self.timeouts = utils.Vars.new('timeouts', self.name)

		-- read the correct timeout variable.
		self.timeouts_enabled = self.timeouts:get() or vim.g.libmodalTimeouts
	end

	return self
end

return Mode
