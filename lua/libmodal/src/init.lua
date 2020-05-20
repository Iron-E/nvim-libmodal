--[[
	/*
	 * MODULE
	 */
--]]

local libmodal = {}

libmodal.globals = require('libmodal/src/globals')
libmodal.mode    = require('libmodal/src/deprecated/mode')
libmodal.Mode    = require('libmodal/src/Mode')
libmodal.prompt  = require('libmodal/src/deprecated/prompt')
libmodal.Prompt  = require('libmodal/src/Prompt')
libmodal.utils   = require('libmodal/src/utils')

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return libmodal
