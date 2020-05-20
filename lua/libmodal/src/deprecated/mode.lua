--[[
	/*
	 * IMPORTS
	 */
--]]

local Mode = require('libmodal/src/Mode')

--[[
	/*
	 * MODULE
	 */
--]]

local mode = {}

mode.ParseTable = Mode.ParseTable

--[[
	/*
	 * LIBRARY `mode`
	 */
--]]

------------------------
--[[ DEPRECATED. ]]
--[[ SUMMARY:
	* Enter a mode.
]]
--[[ PARAMS:
	* `args[1]` => the mode name.
	* `args[2]` => the mode callback, or mode combo table.
	* `args[3]` => optional exit supresion flag.
]]
------------------------
function mode.enter(name, instruction, ...)
	Mode.new(name, instruction, ...):enter()
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return mode
