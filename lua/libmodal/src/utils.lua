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
libmodal.utils = {}
libmodal.utils.Indicator = {}
libmodal.utils.Indicator.Entry = {}

--[[
	/*
	 * INDICATOR
	 */
--]]

-----------------------------------------------
--[[ SUMMARY:
	* Create a new `Indicator`.
]]

--[[ PARAMS:
	* `modeName` => the name of the mode that this `Indicator` is for.
]]
-----------------------------------------------
function libmodal.utils.Indicator:new(modeName)
	return {
		self.Entry.new('LibmodalStar', '*')(),
		self.Entry.new( 'None', '*' )(),
		self.Entry.new( 'LibmodalPrompt', tostring(modeName) )(),
		self.Entry.new('None', ' > ')(),
	}
end

--------------------------------------------------------
--[[ SUMMARY:
	* Create a new `Indicator.Entry`.
]]

--[[ PARAMS:
	* `hlgroup` => The `highlight-group` to be used for this `Indicator.Entry`.
	* `str` => The text for this `Indicator.Entry`.
]]
--------------------------------------------------------
function libmodal.utils.Indicator.Entry.new(hlgroup, str)
	return {hlgroup, str}
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]
return libmodal.utils
