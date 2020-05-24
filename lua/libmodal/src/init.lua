--[[
	/*
	 * MODULE
	 */
--]]

local libmodal = {}

libmodal.classes     = require('libmodal/src/classes')
libmodal.collections = require('libmodal/src/collections')
libmodal.globals     = require('libmodal/src/globals')
libmodal.Indicator   = require('libmodal/src/Indicator')
libmodal.Layer       = require('libmodal/src/Layer')
libmodal.Mode        = require('libmodal/src/Mode')
libmodal.Prompt      = require('libmodal/src/Prompt')
libmodal.utils       = require('libmodal/src/utils')

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return libmodal
