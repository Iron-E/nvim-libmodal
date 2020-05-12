--[[
	/*
	 * IMPORTS
	 */
--]]

local globals = require('libmodal/src/base/globals')
local utils   = require('libmodal/src/utils')

local api  = utils.api
local vars = utils.vars

--[[
	/*
	 * MODULE
	 */
--]]

local mode = {}
mode.ParseTable = require('libmodal/src/mode/ParseTable')

--[[
	/*
	 * LIBRARY `mode`
	 */
--]]

local _TIMEOUT_CHAR = 'ø'
local _TIMEOUT_NR = string.byte(_TIMEOUT_CHAR)
local _TIMEOUT_LEN = api.nvim_get_option('timeoutlen')

----------------------------------------
--[[ SUMMARY:
	* Reset libmodal's internal counter of user input to default.
]]
----------------------------------------
local function _clearLocalInput(modeName)
	vars.input.instances[modeName] = {}
end

----------------------------------------------
--[[ SUMMARY:
	* Update the floating window with the latest user input.
]]
--[[ PARAMS:
	* `modeName` => the name of the mode.
]]
----------------------------------------------
local function _updateFloatingWindow(modeName)
	local uinput = {}
	for _, v in ipairs(vars.input.instances[modeName]) do
		table.insert(uinput, string.char(v))
	end
	api.nvim_buf_set_lines(
		vars.buffers.instances[modeName],
		0, 1, true, {table.concat(uinput)}
	)
end

------------------------------------
--[[ SUMMARY:
	* Parse the `comboDict` and see if there is any command to execute.
]]
--[[ PARAMS:
	* `modeName` => the name of the mode that is currently active.
]]
------------------------------------
local function _comboSelect(modeName)
	-- Stop any running timers
	if vars.timer.instances[modeName] then
		vars.timer.instances[modeName]:stop()
		vars.timer.instances[modeName] = nil
	end

	-- Append the latest input to the locally stored input history.
	table.insert(
		vars.input.instances[modeName],
		vars.nvim_get(vars.input, modeName)
	)

	-- Get the combo dict.
	local comboTable = vars.combos.instances[modeName]

	-- Get the command based on the users input.
	local cmd = comboTable:get(
		vars.input.instances[modeName]
	)

	-- Get the type of the command.
	local commandType = type(cmd)
	local clearInput = false

	-- if there was no matching command
	if cmd == false then clearInput = true
	-- The command was a table, meaning that it MIGHT match.
	elseif commandType == globals.TYPE_TBL then
		-- Create a new timer
		vars.timer.instances[modeName] = vim.loop.new_timer()

		-- start the timer
		vars.timer.instances[modeName]:start(
			_TIMEOUT_LEN, 0, vim.schedule_wrap(function()
				-- Send input to interrupt a blocking `getchar`
				api.nvim_feedkeys(_TIMEOUT_CHAR, '', false)
				-- if there is a command, execute it.
				if cmd[mode.ParseTable.CR] then
					api.nvim_command(cmd[mode.ParseTable.CR])
				end
				-- clear input
				_clearLocalInput(modeName)
				_updateFloatingWindow(modeName)
			end)
		)
	-- The command was an actual vim command.
	else
		api.nvim_command(cmd)
		clearInput = true
	end

	if clearInput then
		_clearLocalInput(modeName)
	end
	_updateFloatingWindow(modeName)
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
local function _initCombos(modeName, comboTable)
	-- Placeholder for timeout value.
	local doTimeout = nil

	-- Read the correct timeout variable.
	if api.nvim_exists('g', vars.timeout:name(modeName)) then
		doTimeout = vars.nvim_get(vars.timeout, modeName)
	else doTimeout = vars.libmodalTimeout end

	-- Assign the timeout variable according to `doTimeout`
	vars.timeout.instances[modeName] = doTimeout

	-- create a floating window
	local buf = api.nvim_create_buf(false, true)
	vars.buffers.instances[modeName] = buf
	vars.windows.instances[modeName] = api.nvim_eval(
		'libmodal#WinOpen(' .. buf .. ')'
	)

	-- Build the parse tree.
	vars.combos.instances[modeName] = mode.ParseTable.new(comboTable)

	-- Initialize the input history variable.
	_clearLocalInput(modeName)
end

-----------------------------------------------------
--[[ SUMMARY:
	* Remove variables used for a mode.
]]
--[[ PARAMS:
	* `modeName` => the name of the mode.
	* `winState` => the window state prior to mode activation.
]]
-----------------------------------------------------
local function _modeEnterTeardown(modeName, winState)
	if vars.windows.instances[modeName] then
		api.nvim_win_close(
			vars.windows.instances[modeName], false
		)
	end

	for _, v in pairs(vars) do
		if type(v) == globals.TYPE_TBL and v.instances[modeName] then
			v.instances[modeName] = nil
		end
	end
	api.nvim_command("mode | echo '' | call garbagecollect()")
	winState:restore()
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
local function _modeLoop(handleExitEvents, indicator, modeInstruction, modeName)
	-- If the mode is not handling exit events automatically and the global exit var is true.
	if not handleExitEvents and globals.isTrue(
		vars.nvim_get(vars.exit, modeName)
	) then return false end

	-- Echo the indicator.
	api.nvim_lecho(indicator)

	-- Capture input.
	local uinput = api.nvim_input()

	-- Return if there was a timeout event.
	if uinput == _TIMEOUT_NR then
		return true
	end

	-- Set the global input variable to the new input.
	vars.nvim_set(vars.input, modeName, uinput)

	-- Make sure that the user doesn't want to exit.
	if handleExitEvents and uinput == globals.ESC_NR then
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
function mode.enter(...)
	local args = {...}

	--[[ SETUP. ]]

	-- Create the indicator for the mode.
	local indicator = utils.Indicator.mode(args[1])

	-- Grab the state of the window.
	local winState = utils.WindowState.new()

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

	_modeEnterTeardown(modeName, winState)
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return mode
