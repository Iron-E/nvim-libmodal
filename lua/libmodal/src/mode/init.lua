--[[
	/*
	 * IMPORTS
	 */
--]]

local globals = require('libmodal/src/base/globals')
local utils   = require('libmodal/src/utils')
local api     = utils.api

--[[
	/*
	 * MODULE
	 */
--]]

local mode = {}

--------------------------------
--[[ SUMMARY:
	* Enter a mode.
]]

--[[ PARAMETERS:
	* `args[1]` => the mode name.
	* `args[2]` => the mode callback, or mode combo table.
	* `args[3]` => optional exit supresion flag.
]]
--------------------------------
function mode.enter(...)
	local args = {...}

	--[[ VAR INIT ]]

	-- Create the indicator for the mode.
	local indicator = utils.Indicator:new(args[1])
	-- Grab the state of the window.
	local winState = utils.WindowState.new()
	-- Convert the name into one that can be used for variables.
	local modeName = string.lower(args[1])
	local handleExitEvents = false
	if #args > 2 and args[3] then
		handleExitEvents = true
	end
	-- Determine whether a callback was specified, or a combo table.
	local doTimeout = nil
	if type(args[2]) == 'table' then
		if api.nvim_exists('g', utils.vars.timeout.name(modeName)) then
			doTimeout = utils.vars.get(vars.timeout, modeName)
		else
			doTimeout = utils.vars.libmodalTimeout
		end
		print(doTimeout)
	end
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]
mode.enter('test', {})
return mode

