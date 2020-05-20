--[[
	/*
	 * IMPORTS
	 */
--]]

local Prompt = require('libmodal/src/Prompt')

--[[
	/*
	 * MODULE
	 */
--]]

local prompt = {}

--------------------------
--[[ DEPRECATED. ]]
--[[ SUMMARY:
	* Enter a prompt.
]]
--[[ PARAMS:
	* `args[1]` => the prompt name.
	* `args[2]` => the prompt callback, or mode command table.
	* `args[3]` => a completions table.
]]
--------------------------
function prompt.enter(name, instruction, ...)
	Prompt.new(name, instruction, ...):enter()
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return prompt
