--[[
	/*
	 * MODULE
	 */
--]]

local libmodal = require('libmodal/src')

--[[
	/*
	 * MIRRORS
	 */
--]]

libmodal.layer = {enter = function(keymap)
	local layer = libmodal.Layer.new(keymap)
	layer:enter()
	return function() layer:exit() end
end}

libmodal.mode = {enter = function(name, instruction, ...)
	libmodal.Mode.new(name, instruction, ...):enter()
end}

libmodal.prompt = {enter = function(name, instruction, ...)
	libmodal.Prompt.new(name, instruction, ...):enter()
end}


--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return libmodal
