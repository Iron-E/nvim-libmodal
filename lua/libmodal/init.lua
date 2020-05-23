--[[
	/*
	 * MODULE
	 */
--]]

local libmodal  = require('libmodal/src')

--[[
	/*
	 * MIRRORS
	 */
--]]

libmodal.mode = {['enter'] = function(name, instruction, ...)
	libmodal.Mode.new(name, instruction, ...):enter()
end}

libmodal.prompt = {['enter'] = function(name, instruction, ...)
	libmodal.Prompt.new(name, instruction, ...):enter()
end}


--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return libmodal
