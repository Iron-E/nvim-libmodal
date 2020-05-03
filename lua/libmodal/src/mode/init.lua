--[[
	/*
	 * IMPORTS
	 */
--]]

local globals    = require('libmodal/src/base/globals')
local ParseTable = require('libmodal/src/mode/ParseTable')
local utils      = require('libmodal/src/utils')

local api  = utils.api
local vars = utils.vars

--[[
	/*
	 * MODULE
	 */
--]]

local mode = {}

------------------------
--[[ SUMMARY:
	* Enter a mode.
]]

--[[ PARAMETERS:
	* `args[1]` => the mode name.
	* `args[2]` => the mode callback, or mode combo table.
	* `args[3]` => optional exit supresion flag.
]]
------------------------
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
	if type(args[2]) == 'table' then
		-- Placeholder for timeout value.
		local doTimeout = nil

		-- Read the correct timeout variable.
		if api.nvim_exists('g', vars.timeout.name(modeName)) then
			doTimeout = vars.nvim_get(vars.timeout, modeName)
		else
			doTimeout = vars.libmodalTimeout
		end


		vars.timeout.instances[modeName] = doTimeout

		vars.combos.instances[modeName] = ParseTable:new(a[2])
	end
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]
mode.enter('test', {})
print(tostring(string.gmatch('testing', '.')))
return mode

