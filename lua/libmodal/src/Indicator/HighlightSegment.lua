--[[
	/*
	 * MODULE
	 */
--]]

local HighlightSegment = {}

--[[
	/*
	 * CLASS `HighlightSegment`
	 */
--]]

--------------------------------
--[[ SUMMARY:
	* Create a new `Indicator.HighlightSegment`.
]]
--[[ PARAMS:
	* `hlgroup` => The `highlight-group` to be used for this `Indicator.HighlightSegment`.
	* `str` => The text for this `Indicator.HighlightSegment`.
]]
--------------------------------
function HighlightSegment.new(hlgroup, str)
	return {
		hl = hlgroup,
		str = str
	}
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return HighlightSegment
