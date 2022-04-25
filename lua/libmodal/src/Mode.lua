local globals    = require 'libmodal/src/globals'
local ParseTable = require 'libmodal/src/collections/ParseTable'
local utils      = require 'libmodal/src/utils'

--- @class libmodal.Mode
--- @field private exit libmodal.utils.Vars
--- @field private flush_input_timer unknown
--- @field private help libmodal.utils.Help|nil
--- @field private indicator libmodal.utils.Indicator
--- @field private input libmodal.utils.Vars
--- @field private instruction function|table<string, function|string>
--- @field private mappings libmodal.collections.ParseTable
--- @field private name string
--- @field private popups libmodal.collections.Stack
--- @field private supress_exit boolean
--- @field private timeouts_enabled boolean
local Mode = utils.classes.new()

local InputBytes = utils.classes.new(
{
	clear = function(self)
		for i, _ in ipairs(self) do
			self[i] = nil
		end
	end
})

local HELP = '?'
local TIMEOUT =
{
	CHAR = 'ø',
	LEN  = vim.go.timeoutlen,
	SEND = function(self) vim.api.nvim_feedkeys(self.CHAR, 'nt', false) end
}
TIMEOUT.CHAR_NUMBER = string.byte(TIMEOUT.CHAR)

--- Execute the `instruction`.
--- @param instruction function|string a Lua function or Vimscript command.
function Mode.execute_instruction(instruction)
	if type(instruction) == globals.TYPE_FUNC then
		instruction()
	else
		vim.api.nvim_command(instruction)
	end
end

--- Check the user's input against the `self.instruction` mappings to see if there is anything to execute.
--- If there is nothing to execute, the user's input is rendered on the screen (as does Vim by default).
function Mode:check_input_for_mapping()
	-- Stop any running timers
	self.flush_input_timer:stop()

	-- Append the latest input to the locally stored input history.
	self.input_bytes[#self.input_bytes + 1] = self.input:get()

	-- Get the command based on the users input.
	local cmd = self.mappings:get(self.input_bytes)

	-- Get the type of the command.
	local command_type = type(cmd)

	-- if there was no matching command
	if not cmd then
		if #self.input_bytes < 2 and self.input_bytes[1] == string.byte(HELP) then
			self.help:show()
		end
		self.input_bytes:clear()
	-- The command was a table, meaning that it MIGHT match.
	elseif command_type == globals.TYPE_TBL
		and globals.is_true(self.timeouts_enabled)
	then
		-- start the timer
		self.flush_input_timer:start(
			TIMEOUT.LEN, 0, vim.schedule_wrap(function()
				-- Send input to interrupt a blocking `getchar`
				TIMEOUT:SEND()
				-- if there is a command, execute it.
				if cmd[ParseTable.CR] then
					self.execute_instruction(cmd[ParseTable.CR])
				end
				-- clear input
				self.input_bytes:clear()
				self.popups:peek():refresh(self.input_bytes)
			end)
		)

	-- The command was an actual vim command.
	else
		self.execute_instruction(cmd)
		self.input_bytes:clear()
	end

	self.popups:peek():refresh(self.input_bytes)
end

--- Enter this mode.
function Mode:enter()
	-- intialize variables that are needed for each recurse of a function
	if type(self.instruction) == globals.TYPE_TBL then
		-- Initialize the input history variable.
		self.popups:push(utils.Popup.new())
	end

	self.previous_mode_name = vim.g.libmodalActiveModeName
	vim.g.libmodalActiveModeName = self.name

	--[[ MODE LOOP. ]]
	local continue_mode = true
	while continue_mode do
		-- Try (using pcall) to use the mode.
		local no_errors, mode_result = pcall(self.get_user_input, self)

		-- If there were errors, handle them.
		if not no_errors then
			utils.show_error(mode_result)
			continue_mode = false
		else
			continue_mode = mode_result
		end
	end

	self:tear_down()
end

--- Get input from the user.
--- @return boolean more_input
function Mode:get_user_input()
	-- If the mode is not handling exit events automatically and the global exit var is true.
	if self.supress_exit and globals.is_true(self.exit:get()) then
		return false
	end

	-- Echo the indicator.
	utils.api.nvim_lecho(self.indicator)

	-- Capture input.
	local user_input = vim.fn.getchar()

	-- Return if there was a timeout event.
	if user_input == TIMEOUT.CHAR_NUMBER then
		return true
	end

	-- Set the global input variable to the new input.
	self.input:set(user_input)

	if not self.supress_exit and user_input == globals.ESC_NR then -- The user wants to exit.
		return false -- As in, "I don't want to continue."
	else -- The user wants to continue.

		--[[ The instruction type is determined every cycle, because the user may be assuming a more direct control
			over the instruction and it may change over the course of execution. ]]
		local instruction_type = type(self.instruction)

		if instruction_type == globals.TYPE_TBL then -- The instruction was provided as a was a set of mappings.
			self:check_input_for_mapping()
		elseif instruction_type == globals.TYPE_STR then -- The instruction is the name of a Vimscript function.
			vim.fn[self.instruction]()
		else -- The instruction is a function.
			self.instruction()
		end
	end

	return true
end

--- Uninitialize variables from after exiting the mode.
function Mode:tear_down()
	if type(self.instruction) == globals.TYPE_TBL then
		self.flush_input_timer:stop()
		self.input_bytes = nil

		self.popups:pop():close()
	end

	if self.previous_mode_name and #vim.trim(self.previous_mode_name) < 1 then
		vim.g.libmodalActiveModeName = nil
	else
		vim.g.libmodalActiveModeName = self.previous_mode_name
	end

	utils.api.nvim_redraw()
end

return
{
	--- Create a new mode.
	--- @param name string the name of the mode.
	--- @param instruction function|string|table a Lua function, keymap dictionary, Vimscript command.
	--- @return libmodal.Mode
	new = function(name, instruction, supress_exit)
		name = vim.trim(name)

		-- Inherit the metatable.
		local self = setmetatable(
			{
				exit = utils.Vars.new('exit', name),
				indicator = utils.Indicator.mode(name),
				input = utils.Vars.new('input', name),
				instruction = instruction,
				name = name,
			},
			Mode
		)

		-- Define the exit flag
		self.supress_exit = supress_exit or false

		-- If the user provided keymaps
		if type(instruction) == globals.TYPE_TBL then
			-- Create a timer to perform actions with.
			self.flush_input_timer = vim.loop.new_timer()

			-- Determine if a default `Help` should be created.
			if not self.instruction[HELP] then
				self.help = utils.Help.new(self.instruction, 'KEY MAP')
			end

			self.input_bytes = setmetatable({}, InputBytes)

			-- Build the parse tree.
			self.mappings = ParseTable.new(self.instruction)

			-- Create a table for mode-specific data.
			self.popups = require('libmodal/src/collections/Stack').new()

			-- Create a variable for whether or not timeouts are enabled.
			self.timeouts = utils.Vars.new('timeouts', self.name)

			-- Read the correct timeout variable.
			self.timeouts_enabled = self.timeouts:get() or vim.g.libmodalTimeouts
		end

		return self
	end
}
