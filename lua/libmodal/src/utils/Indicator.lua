local MODE_HIGHLIGHT    = 'LibmodalPrompt'
local PROMPT_HIGHLIGHT  = 'LibmodalStar'

--- @class libmodal.utils.Indicator
--- @field public hl string the highlight group to use when printing `str`
--- @field public str string the text to write
local Indicator = {}

--- @param highlight_group string the highlight group to use when printing `str`
--- @param str string what to print
--- @return libmodal.utils.Indicator
function Indicator.new(highlight_group, str)
	return
	{
		hl = highlight_group,
		str = str,
	}
end

function Indicator.mode(mode_name)
	return Indicator.new(MODE_HIGHLIGHT, '-- ' .. mode_name .. ' --')
end

function Indicator.prompt(prompt_name)
	return Indicator.new(PROMPT_HIGHLIGHT, '* ' .. prompt_name .. ' > ')
end

return Indicator
