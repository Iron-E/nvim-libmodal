--- @class libmodal
--- @field private collections libmodal.collections
--- @field private globals libmodal.globals
--- @field private Layer libmodal.Layer
--- @field private Mode libmodal.Mode
--- @field private Prompt libmodal.Prompt
--- @field private utils libmodal.utils
return
{
	collections = require 'libmodal/src/collections',
	globals     = require 'libmodal/src/globals',
	Layer       = require 'libmodal/src/Layer',
	Mode        = require 'libmodal/src/Mode',
	Prompt      = require 'libmodal/src/Prompt',
	utils       = require 'libmodal/src/utils',
}
