--[[
	/*
	 * IMPORTS
	 */
--]]

local classes    = require('libmodal/src/classes')
local globals    = require('libmodal/src/globals')
local ParseTable = require('libmodal/src/collections/ParseTable')
local utils      = require('libmodal/src/utils')
local Vars       = require('libmodal/src/Vars')

local vim = vim
local api = vim.api

--[[
	/*
	 * MODULE
	 */
--]]

local Mode = {['TYPE']  = 'libmodal-mode'}

local _HELP = '?'
local _TIMEOUT = {
	['CHAR'] = 'ø',
	['LEN']  = api.nvim_get_option('timeoutlen'),
	['SEND'] = function(__self)
		api.nvim_feedkeys(__self.CHAR, 'nt', false)
	end
}
_TIMEOUT.NR = string.byte(_TIMEOUT.CHAR)

--[[
	/*
	 * META `_metaMode`
	 */
--]]

local _metaMode = classes.new(Mode.TYPE)

local _metaInputBytes = classes.new(nil, {
	['clear'] = function(__self)
		for i, _ in ipairs(__self) do
			__self[i] = nil
		end
	end
})

classes = nil

-----------------------------------------------------------
--[[ SUMMARY:
	* Execute some `selection` according to a set of determined logic.
]]
--[[ REMARKS:
	* Only provides logic for when `self._instruction` is a table of commands.
]]
--[[ PARAMS:
	* `selection` => The instruction that is desired to be executed.
]]
-----------------------------------------------------------
function _metaMode._commandTableExecute(instruction)
	if type(instruction) == globals.TYPE_FUNC then instruction()
	else api.nvim_command(instruction) end
end

-----------------------------------------------
--[[ SUMMARY:
	* Parse `self.mappings` and see if there is any command to execute.
]]
-----------------------------------------------
function _metaMode:_checkInputForMapping()
	-- Stop any running timers
	self._flushInputTimer:stop()

	-- Append the latest input to the locally stored input history.
	local inputBytes = self.inputBytes

	inputBytes[#inputBytes + 1] = self.input:nvimGet()

	-- Get the command based on the users input.
	local cmd = self.mappings:get(inputBytes)

	-- Get the type of the command.
	local commandType = type(cmd)

	-- if there was no matching command
	if not cmd then
		if #inputBytes < 2 and inputBytes[1] == string.byte(_HELP) then
			self._help:show()
		end
		inputBytes:clear()
	-- The command was a table, meaning that it MIGHT match.
	elseif commandType == globals.TYPE_TBL
		and globals.is_true(self._timeouts.enabled)
	then
		-- start the timer
		self._flushInputTimer:start(
			_TIMEOUT.LEN, 0, vim.schedule_wrap(function()
				-- Send input to interrupt a blocking `getchar`
				_TIMEOUT:SEND()
				-- if there is a command, execute it.
				if cmd[ParseTable.CR] then
					self._commandTableExecute(cmd[ParseTable.CR])
				end
				-- clear input
				inputBytes:clear()
				self._popups:peek():refresh(inputBytes)
			end)
		)

	-- The command was an actual vim command.
	else
		self._commandTableExecute(cmd)
		inputBytes:clear()
	end

	self._popups:peek():refresh(inputBytes)
end

--------------------------
--[[ SUMMARY:
	* Enter `self`'s mode.
]]
--------------------------
function _metaMode:enter()
	-- intialize variables that are needed for each recurse of a function
	if type(self._instruction) == globals.TYPE_TBL then
		-- Initialize the input history variable.
		self._popups:push(require('libmodal/src/collections/Popup').new())
	end

	if vim.b then -- requires neovim 0.5
		self._previousModeName = vim.b.libmodalActiveModeName
		vim.b.libmodalActiveModeName = self._name
	end

	--[[ MODE LOOP. ]]
	local continueMode = true
	while continueMode do
		-- Try (using pcall) to use the mode.
		local noErrors, modeResult = pcall(self._inputLoop, self)

		-- If there were errors, handle them.
		if not noErrors then
			utils.show_error(modeResult)
			continueMode = true
		else
			continueMode = modeResult
		end
	end

	self:_tearDown()
end

----------------------------------
--[[ SUMMARY:
	* Set the initial values used for parsing user input as combos.
]]
----------------------------------
function _metaMode:_initMappings()
	-- Create a timer to perform actions with.
	self._flushInputTimer = vim.loop.new_timer()

	-- Determine if a default `Help` should be created.
	if not self._instruction[_HELP] then
		self._help = utils.Help.new(self._instruction, 'KEY MAP')
	end

	self.inputBytes = setmetatable({}, _metaInputBytes)

	-- Build the parse tree.
	self.mappings = ParseTable.new(self._instruction)

	-- Create a table for mode-specific data.
	self._popups = require('libmodal/src/collections/Stack').new()

	-- Create a variable for whether or not timeouts are enabled.
	self._timeouts = Vars.new('timeouts', self._name)

	-- Read the correct timeout variable.
	if utils.api.nvim_exists('g', self._timeouts:name())
	then self._timeouts.enabled =
		self._timeouts:nvimGet()
	else self._timeouts.enabled =
		Vars.libmodalTimeouts
	end
end

-------------------------------
--[[ SUMMARY:
	* Loop an initialized `mode`.
]]
--[[ RETURNS:
	* `boolean` => whether or not the mode should continue
]]
-------------------------------
function _metaMode:_inputLoop()
	-- If the mode is not handling exit events automatically and the global exit var is true.
	if self.exit.supress
	   and globals.is_true(self.exit:nvimGet())
	then
		return false
	end

	-- Echo the indicator.
	utils.api.nvim_lecho(self.indicator)

	-- Capture input.
	local userInput = utils.api.nvim_input()

	-- Return if there was a timeout event.
	if userInput == _TIMEOUT.NR then
		return true
	end

	-- Set the global input variable to the new input.
	self.input:nvimSet(userInput)

	if not self.exit.supress and userInput == globals.ESC_NR then -- The user wants to exit.
		return false -- As in, "I don't want to continue."
	else -- The user wants to continue.

		--[[ The instruction type is determined every cycle, because the user may be assuming a more direct control
			over the instruction and it may change over the course of execution. ]]
		local instructionType = type(self._instruction)

		if instructionType == globals.TYPE_TBL then -- The second argument was a dict. Parse it.
			self:_checkInputForMapping()
		elseif instructionType == globals.TYPE_STR and vim.fn then -- It is the name of a VimL function. This only works in Neovim 0.5+.
			vim.fn[self._instruction]()
		else -- the second argument was a function; execute it.
			self._instruction()
		end
	end

	return true
end

------------------------------
--[[ SUMMARY:
	* Remove variables used for a mode.
]]
------------------------------
function _metaMode:_tearDown()
	if type(self._instruction) == globals.TYPE_TBL then
		self._flushInputTimer:stop()
		self.inputBytes = nil

		self._popups:pop():close()
	end

	if vim.b then -- this step requires 0.5
		vim.b.libmodalActiveModeName = self._previousModeName
	end

	self._winState:restore()
	utils.api.nvim_redraw()
end

--[[
	/*
	 * CLASS `Mode`
	 */
--]]

-----------------------------------------
--[[ SUMMARY:
	* Enter a mode.
]]
--[[ PARAMS:
	* `name` => the mode name.
	* `instruction` => the mode callback, or mode combo table.
	* `...` => optional exit supresion flag.
]]
-----------------------------------------
function Mode.new(name, instruction, ...)
	name = vim.trim(name)

	-- Inherit the metatable.
	local self = setmetatable(
		{
			['exit']         = Vars.new('exit', name),
			['indicator']    = require('libmodal/src/Indicator').mode(name),
			['input']        = Vars.new('input', name),
			['_instruction'] = instruction,
			['_name']        = name,
			['_winState']    = utils.WindowState.new(),
		},
		_metaMode
	)

	-- Define the exit flag
	self.exit.supress = (function(optionalValue)
		if optionalValue then
			return globals.is_true(optionalValue)
		else
			return false
		end
	end)(unpack({...}))

	-- Define other "session" variables.

	-- Determine whether a callback was specified, or a combo table.
	if type(instruction) == globals.TYPE_TBL then
		self:_initMappings()
	end

	return self
end

--[[
	/
	 * PUBLICIZE MODULE
	 */
--]]

return Mode
