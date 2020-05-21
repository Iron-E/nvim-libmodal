--[[
	/*
	 * MODULE
	 */
--]]

local libmodal = {}

libmodal.classes    = require('libmodal/src/classes')
libmodal.collection = require('libmodal/src/collections')
libmodal.globals    = require('libmodal/src/globals')
libmodal.Indicator  = require('libmodal/src/Indicator')
libmodal.Mode       = require('libmodal/src/Mode')
libmodal.Prompt     = require('libmodal/src/Prompt')
libmodal.utils      = require('libmodal/src/utils')

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
