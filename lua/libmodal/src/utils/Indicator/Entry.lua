--[[
	/*
	 * MODULE
	 */
--]]
local Entry = {}

--[[
	/*
	 * STRUCT `Entry`
	 */
--]]

--------------------------------------------------------
--[[ SUMMARY:
	* Create a new `Indicator.Entry`.
]]

--[[ PARAMS:
	* `hlgroup` => The `highlight-group` to be used for this `Indicator.Entry`.
	* `str` => The text for this `Indicator.Entry`.
]]
--------------------------------------------------------
function Entry.new(hlgroup, str)
	return {hlgroup, str}
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]
return Entry