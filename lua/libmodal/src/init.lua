--- @class libmodal
--- @field collections libmodal.collections
--- @field globals libmodal.globals
--- @field Layer libmodal.Layer
--- @field Mode libmodal.Mode
--- @field Prompt libmodal.Prompt
--- @field utils libmodal.utils
local libmodal =
{
	collections = require 'libmodal/src/collections',
	globals = require 'libmodal/src/globals',
	Layer = require 'libmodal/src/Layer',
	Mode = require 'libmodal/src/Mode',
	Prompt = require 'libmodal/src/Prompt',
	utils = require 'libmodal/src/utils',
}

return libmodal
