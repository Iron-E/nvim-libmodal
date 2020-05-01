--[[
	/*
	 * IMPORTS
	 */
--]]
local libmodal = require('libmodal/src')

--[[
	/*
	 * MODULE
	 */
--]]
libmodal.prompt = {}

----------------------------------
--[[ SUMMARY:
	* Enter a prompt.
]]

--[[ PARAMETERS:
	* `args[1]` => the prompt name.
	* `args[2]` => the prompt callback, or mode command table.
]]
----------------------------------
function libmodal.prompt.enter(...)
	local args = {...}
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]
return libmodal.prompt
