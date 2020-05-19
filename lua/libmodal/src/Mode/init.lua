--[[
	/*
	 * IMPORTS
	 */
--]]

local globals = require('libmodal/src/globals')
local utils   = require('libmodal/src/utils')
local Vars    = require('libmodal/src/Vars')

local api  = utils.api

--[[
	/*
	 * MODULE
	 */
--]]

-- Public interface for this module.
local Mode = {}

-- Private class.
local _modeMetaTable = {}

_modeMetaTable.ParseTable = require('libmodal/src/mode/ParseTable')

local _HELP = '?'
local _TIMEOUT = {
	CHAR = 'ø',
	NR   = string.byte(_TIMEOUT.CHAR),
	LEN  = api.nvim_get_option('timeoutlen'),
	SEND = function(__self)
		api.nvim_feedkeys(__self.CHAR, '', false)
	end
}

--[[
	/*
	 * META `_modeMetaTable`
	 */
--]]

----------------------------------------
--[[ SUMMARY:
	* Reset libmodal's internal counter of user input to default.
]]
----------------------------------------
function _modeMetaTable:clearInputBytes()
	self._inputBytes = {}
end

-----------------------------------------------
--[[ SUMMARY:
	* Update the floating window with the latest user input.
]]
--[[ PARAMS:
	* `modeName` => the name of the mode.
]]
-----------------------------------------------
function _modeMetaTable:_updateFloatingWindow()
	local inputChars = {}
	for _, byte in ipairs(self._inputBytes) do
		inputChars[#inputChars + 1] = string.char(byte)
	end
	api.nvim_buf_set_lines(
		self._popupBuffer,
		0, 1, true, {table.concat(inputChars)}
	)
end

--------------------------------------
--[[ SUMMARY:
	* Parse the `comboDict` and see if there is any command to execute.
]]
--[[ PARAMS:
	* `modeName` => the name of the mode that is currently active.
]]
--------------------------------------
function _modeMetaTable:_comboSelect()
	-- Stop any running timers
	if self._flushInputTimer then
		self._flushInputTimer:stop()
	end

	-- Append the latest input to the locally stored input history.
	self._inputBytes[#self._inputBytes + 1] = Vars.nvim_get(
		self._inputBytes, self._modeName
	)

	-- Get the command based on the users input.
	local cmd = self._keybindings:get(self._inputBytes)

	-- Get the type of the command.
	local commandType = type(cmd)
	local clearInputBytes = false

	-- if there was no matching command
	if cmd == false then
		if #self._inputBytes < 2 and self._inputBytes[1] == string.byte(_HELP) then
			self._help:show()
		end
		clearInputBytes = true
	-- The command was a table, meaning that it MIGHT match.
	elseif commandType == globals.TYPE_TBL
	       and globals.isTrue(self._timeoutsEnabled)
	then
		-- Create a new timer

		-- start the timer
		self._flushInputTimer:start(
			_TIMEOUT.LEN, 0, vim.schedule_wrap(function()
				-- Send input to interrupt a blocking `getchar`
				_TIMEOUT:SEND()
				-- if there is a command, execute it.
				if cmd[self.ParseTable.CR] then
					api.nvim_command(cmd[self.ParseTable.CR])
				end
				-- clear input
				_clearInputBytes(modeName)
				_updateFloatingWindow(modeName)
			end)
		)
	-- The command was an actual vim command.
	else
		api.nvim_command(cmd)
		clearInputBytes = true
	end

	if clearInputBytes then
		self:_clearInputBytes()
	end
	self:_updateFloatingWindow()
end

------------------------------------------------
--[[ SUMMARY:
	* Set the initial values used for parsing user input as combos.
]]
--[[ PARAMS:
	* `modeName` => the name of the mode being initialized.
	* `comboTable` => the table of combos being initialized.
]]
------------------------------------------------
-- TODO
local function _initCombos(modeName, comboTable)
	-- Placeholder for timeout value.
	local timeoutsEnabled = nil

	-- Read the correct timeout variable.
	if api.nvim_exists('g', vars.timeouts:name(modeName)) then timeoutsEnabled =
		vars.nvim_get(vars.timeouts, modeName)
	else timeoutsEnabled =
		vars.libmodalTimeouts
	end

	-- Assign the timeout variable according to `timeoutsEnabled`
	self._timeoutsEnabled = timeoutsEnabled

	-- create a floating window
	local buf = api.nvim_create_buf(false, true)
	vars.buffers.instances[modeName] = buf
	self._popupWindow = api.nvim_call_function('libmodal#_winOpen', {buf})

	-- Determine if a default `Help` should be created.
	if not comboTable[_HELP] then
		vars.help.instances[modeName] = utils.Help.new(comboTable, 'KEY MAP')
	end

	-- Build the parse tree.
	vars.combos.instances[modeName] = mode.ParseTable.new(comboTable)

	-- Create a timer
	self._flushInputTimer = vim.loop.new_timer()

	-- Initialize the input history variable.
	_clearInputBytes(modeName)
end

-----------------------------------------------------
--[[ SUMMARY:
	* Remove variables used for a mode.
]]
--[[ PARAMS:
	* `modeName` => the name of the mode.
	* `self._winState` => the window state prior to mode activation.
]]
-----------------------------------------------------
function _modeMetaTable:_deconstruct()
	if self._flushInputTimer:info()['repeat'] ~= 0 then
		self._flushInputTimer:stop()
	end

	if self._popupWindow then
		api.nvim_win_close(self._popupWindow, false)
	end

	self._winState:restore()

	for k, _ in pairs(self) do
		self[k] = nil
	end

	api.nvim_command("mode | echo '' | call garbagecollect()")
end

--------------------------------------------------------------------------------
--[[ SUMMARY:
	* Loop an initialized `mode`.
]]
--[[ PARAMS:
	* `handleExitEvents` => whether or not to automatically exit on `<Esc>` press.
	* `indicator` => the indicator for the mode.
	* `modeInstruction` => the instructions for the mode.
	* `modeName` => the name of the `mode`.
]]
--[[ RETURNS:
	* `boolean` => whether or not the mode should continue
]]
--------------------------------------------------------------------------------
-- TODO
local function _modeLoop(handleExitEvents, indicator, modeInstruction, modeName)
	-- If the mode is not handling exit events automatically and the global exit var is true.
	if not handleExitEvents and globals.isTrue(
		vars.nvim_get(vars.exit, modeName)
	) then return false end

	-- Echo the indicator.
	api.nvim_lecho(indicator)

	-- Capture input.
	local userInput = api.nvim_input()

	-- Return if there was a timeout event.
	if userInput == _TIMEOUT.NR then
		return true
	end

	-- Set the global input variable to the new input.
	vars.nvim_set(vars.input, modeName, userInput)

	-- Make sure that the user doesn't want to exit.
	if handleExitEvents and userInput == globals.ESC_NR then
		return false
	-- If the second argument was a dict, parse it.
	elseif type(modeInstruction) == globals.TYPE_TBL then
		_comboSelect(modeName)
	-- If the second argument was a function, execute it.
	else modeInstruction() end

	return true
end

------------------------
--[[ SUMMARY:
	* Enter a mode.
]]
--[[ PARAMS:
	* `args[1]` => the mode name.
	* `args[2]` => the mode callback, or mode combo table.
	* `args[3]` => optional exit supresion flag.
]]
------------------------
-- TODO
function _modeMetaTable:enter(...)
	local args = {...}

	--[[ SETUP. ]]

	-- Create the indicator for the mode.
	local indicator = utils.Indicator.mode(args[1])

	-- Grab the state of the window.
	self._winState = utils.WindowState.new()

	-- Convert the name into one that can be used for variables.
	local modeName = string.lower(args[1])

	-- Determine whether or not this function should handle exiting automatically.
	local handleExitEvents = true
	if #args > 2 then
		handleExitEvents = globals.isFalse(args[3])
	end

	-- Determine whether a callback was specified, or a combo table.
	if type(args[2]) == globals.TYPE_TBL then
		_initCombos(modeName, args[2])
	end

	--[[ MODE LOOP. ]]
	local continueMode = true
	while continueMode == true do
		-- Try (using pcall) to use the mode.
		local noErrors = true
		noErrors, continueMode = pcall(_modeLoop,
			handleExitEvents, indicator, args[2], modeName
		)

		-- If there were errors, handle them.
		if noErrors == false then
			utils.showError(continueMode)
			continueMode = false
		end

	end
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return Mode
