--[[
	/*
	 * IMPORTS
	 */
--]]

local globals    = require('libmodal/src/base/globals')
local utils      = require('libmodal/src/utils')

local api  = utils.api
local vars = utils.vars

--[[
	/*
	 * MODULE
	 */
--]]

local mode = {}
mode.ParseTable = require('libmodal/src/mode/ParseTable')

------------------------------------
--[[ SUMMARY:
	* Parse the `comboDict` and see if there is any command to execute.
]]
--[[ PARAMS:
	* `modeName` => the name of the mode that is currently active.
]]
------------------------------------
function mode._comboSelect(modeName)
	local comboDict = vars.combos.instances[modeName]
	-- TODO translate `LibmodalEnterWithCombos`
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
	local indicator = utils.Indicator:new(args[1])

	-- Grab the state of the window.
	local winState = utils.WindowState.new()

	-- Convert the name into one that can be used for variables.
	local modeName = string.lower(args[1])

	-- Determine whether or not this function should handle exiting automatically.
	local handleExitEvents = false
	if #args > 2 and args[3] then
		handleExitEvents = true
	end

	-- Determine whether a callback was specified, or a combo table.
	if type(args[2]) == globals.TYPE_TBL then
		mode._initTimeouts(modeName)
	end

	--[[ MODE LOOP. ]]

	while true do
		-- Try (using pcall) to use the mode.
		local noErrors = pcall(function()
			-- If the mode is not handling exit events automatically and the global exit var is true.
			if not handleExitEvents and var.nvim_get(vars.exit, modeName) then
				break
			end

			-- Echo the indicator.
			api.nvim_lecho(indicator)

			-- Capture input.
			local uinput = api.nvim_input()
			vars.nvim_set(vars.input, modeName, uinput)

			-- Make sure that the user doesn't want to exit.
			if handleExitEvents and uinput == globals.ESC_NR then
				break
			-- If the second argument was a dict, parse it.
			elseif type(args[2]) == globals.TYPE_TBL then
				mode._comboSelect(modeName)
			-- If the second argument was a function, execute it.
			else
				args[2]()
			end

		end)()

		-- If there were errors, handle them.
		if not noErrors then
			mode._showError()
			break
		end
	end

	--[[ TEARDOWN. ]]
	api.nvim_redraw()
	api.nvim_echo('')
	api.nvim_command('call garbagecollect()')
	winState:restore()
end

function mode._initTimeouts(modeName)
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
	vars.combos.instances[modeName] = mode.ParseTable:new(args[2])

	-- Initialize the input history variable.
	vars.input.instances[modeName] = {}
end

function mode._showError()
	api.nvim_bell()
	api.nvim_show_err( 'vim-libmodal error',
		api.nvim_get_vvar('throwpoint')
		.. '\n' ..
		api.nvim_get_vvar('exception')
	)
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]
mode.enter('test', {})
return mode

