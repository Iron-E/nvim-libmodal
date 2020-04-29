--[[
	/*
	 * IMPORTS
	 */
]]
local libmodal = require('src.libmodal')

--[[
	/*
	 * MODULE
	 */
]]
libmodal.mode = {}

--[[SUMMARY: Enter a mode.

	PARAMETERS:
	`args[1]` => the mode name.
	`args[2]` => the mode callback, or mode combo table.
	`args[3]` => optional exit supresion flag.
]]
function libmodal.mode.enter(...)
	local args = {...}
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
]]
return libmodal.mode
