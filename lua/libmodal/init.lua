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

libmodal.layer = {['enter'] = function(name, mappings)
	local layer = libmodal.Layer.new(name, mappings)
	layer:enter()
	return layer.exit
end}

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
