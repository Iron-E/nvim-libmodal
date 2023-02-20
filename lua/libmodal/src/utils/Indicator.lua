--- @class libmodal.utils.Indicator
--- @field hl string the highlight group to use when printing `str`
--- @field str string the text to write
local Indicator = {}

--- @param highlight_group string the highlight group to use when printing `str`
--- @param str string what to print
--- @return libmodal.utils.Indicator
function Indicator.new(highlight_group, str)
	return {hl = highlight_group, str = str}
end

return Indicator
