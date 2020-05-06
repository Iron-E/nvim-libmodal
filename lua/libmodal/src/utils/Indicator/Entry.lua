--[[
	/*
	 * MODULE
	 */
--]]
local Entry = {}

--[[
	/*
	 * CLASS `Entry`
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
	return {
		['hl'] = hlgroup,
		['str'] = str
	}
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]
return Entry
