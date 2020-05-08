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

local TIMEOUT_CHAR = 'ø'
local TIMEOUT_NR = api.nvim_eval("char2nr('" .. TIMEOUT_CHAR .. "')")
local TIMEOUT_LEN = api.nvim_get_option('TIMEOUT_LEN')

----------------------------------------
--[[ SUMMARY:
	* Reset libmodal's internal counter of user input to default.
]]
----------------------------------------
local function clearLocalInput(modeName)
	vars.input.instances[modeName] = {}
end

------------------------------------
--[[ SUMMARY:
	* Parse the `comboDict` and see if there is any command to execute.
]]
--[[ PARAMS:
	* `modeName` => the name of the mode that is currently active.
]]
------------------------------------
local function comboSelect(modeName)
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
	if commandType == false then clearInput = true
	-- The command was a table, meaning that it MIGHT match.
	elseif commandType == globals.TYPE_TBL then
		-- Create a new timer
		vars.timer.instances[modeName] = vim.loop.new_timer()

		-- start the timer
		vars.timer.instances[modeName]:start(TIMEOUT_LEN, 0,
			vim.schedule_wrap(function()
				-- Send input to interrupt a blocking `getchar`
				api.nvim_feedkeys(TIMEOUT_CHAR, '', false)
				-- if there is a command, execute it.
				if cmd[mode.ParseTable.CR] then
					api.nvim_command(cmd[mode.ParseTable.CR])
				end
				-- clear input
				clearLocalInput(modeName)
			end)
		)
	-- The command was an actual vim command.
	else
		api.nvim_command(cmd)
		clearInput = true
	end

	if clearInput then
		clearLocalInput(modeName)
	end
end

-------------------------------------------------
--[[ SUMMARY:
	* Set the initial values used for parsing user input as combos.
]]
--[[ PARAMS:
	* `modeName` => the name of the mode being initialized.
	* `comboTable` => the table of combos being initialized.
]]
-------------------------------------------------
local function initCombos(modeName, comboTable)
	-- Placeholder for timeout value.
	local doTimeout = nil

	-- Read the correct timeout variable.
	if api.nvim_exists('g', vars.timeout.name(modeName)) then
		doTimeout = vars.nvim_get(vars.timeout, modeName)
	else
		doTimeout = vars.libmodalTimeout
	end
	vars.timeout.instances[modeName] = doTimeout

	-- Build the parse tree.
	vars.combos.instances[modeName] = mode.ParseTable.new(comboTable)

	-- Initialize the input history variable.
	clearLocalInput(modeName)
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
	local indicator = utils.Indicator.new(args[1])

	-- Grab the state of the window.
	local winState = utils.WindowState.new()

	-- Convert the name into one that can be used for variables.
	local modeName = string.lower(args[1])

	-- Determine whether or not this function should handle exiting automatically.
	local handleExitEvents = true
	if #args > 2 then
		handleExitEvents = args[3] == true
	end

	-- Determine whether a callback was specified, or a combo table.
	if type(args[2]) == globals.TYPE_TBL then
		initCombos(modeName, args[2])
	end

	--[[ MODE LOOP. ]]

	local continueMode = true
	while continueMode do
		-- Try (using pcall) to use the mode.
		local noErrors = pcall(function()
			-- If the mode is not handling exit events automatically and the global exit var is true.
			if not handleExitEvents and vars.nvim_get(vars.exit, modeName) then
				continueMode = false
				return
			end

			-- Echo the indicator.
			api.nvim_lecho(indicator)

			-- Capture input.
			local uinput = api.nvim_input()

			-- Return if there was a timeout event.
			if uinput == TIMEOUT_NR then return end

			-- Set the global input variable to the new input.
			vars.nvim_set(vars.input, modeName, uinput)

			-- Make sure that the user doesn't want to exit.
			if handleExitEvents and uinput == globals.ESC_NR then
				continueMode = false
				return
			-- If the second argument was a dict, parse it.
			elseif type(args[2]) == globals.TYPE_TBL then
				comboSelect(modeName)
			-- If the second argument was a function, execute it.
			else args[2]() end
		end)

		-- If there were errors, handle them.
		if not noErrors then
			utils.showError()
			continueMode = false
		end
	end

	--[[ TEARDOWN. ]]
	api.nvim_redraw()
	api.nvim_echo('')
	api.nvim_command('call garbagecollect()')
	winState:restore()
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return mode
