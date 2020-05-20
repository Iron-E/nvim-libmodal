--[[
	/*
	 * MODULE
	 */
--]]

local Indicator = {}

Indicator.HighlightSegment = require('libmodal/src/Indicator/HighlightSegment')

-- highlight group names
local _HL_GROUP_MODE    = 'LibmodalPrompt'
local _HL_GROUP_PROMPT  = 'LibmodalStar'

-- predefined segments
local _SEGMENT_MODE_BEGIN = Indicator.HighlightSegment.new(_HL_GROUP_MODE, '-- ')
local _SEGMENT_MODE_END   = Indicator.HighlightSegment.new(_HL_GROUP_MODE, ' --')
local _PROMPT_TEMPLATE = {'* ', ' > '}

--[[
	/*
	 * META `Indicator`
	 */
--]]

--[[
	/*
	 * CLASS `Indicator`
	 */
--]]

---------------------------------
--[[ SUMMARY:
	* Create a new `Indicator` for a mode.
]]
--[[ PARAMS:
	* `modeName` => the name of the mode that this `Indicator` is for.
]]
---------------------------------
function Indicator.mode(modeName)
	return {
		[1] = _SEGMENT_MODE_BEGIN,
		[2] = Indicator.HighlightSegment.new(
			_HL_GROUP_MODE, tostring(modeName)
		),
		[3] = _SEGMENT_MODE_END,
	}
end

-----------------------------------
--[[ SUMMARY:
	* Create a new `Indicator` for a prompt.
]]
--[[ PARAMS:
	* `modeName` => the name of the mode that this `Indicator` is for.
]]
-----------------------------------
function Indicator.prompt(modeName)
	return Indicator.HighlightSegment.new(
		_HL_GROUP_PROMPT,
		table.concat(_PROMPT_TEMPLATE, modeName)
	)
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return Indicator
