--[[
	/*
	 * IMPORTS
	 */
--]]

local Entry = require('libmodal/src/utils/Indicator/Entry')

--[[
	/*
	 * MODULE
	 */
--]]

local Indicator = {}

--[[
	/*
	 * CLASS `Indicator`
	 */
--]]

--------------------------------
--[[ SUMMARY:
	* Create a new `Indicator`.
]]
--[[ PARAMS:
	* `modeName` => the name of the mode that this `Indicator` is for.
]]
--------------------------------
function Indicator:new(modeName)
	return {
		Entry.new('LibmodalStar', '*'),
		Entry.new( 'None', '*' ),
		Entry.new( 'LibmodalPrompt', tostring(modeName) ),
		Entry.new('None', ' > '),
	}
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return Indicator
