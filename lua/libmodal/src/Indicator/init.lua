--[[
	/*
	 * MODULE
	 */
--]]

local Indicator = {}

Indicator.HighlightSegment = require('libmodal/src/Indicator/HighlightSegment')

-- highlight group names
local _HL_GROUP_PROMPT = 'LibmodalPrompt'
local _HL_GROUP_STAR   = 'LibmodalStar'
local _HL_GROUP_NONE   = 'None'

-- `libmodal.mode` `HighlightSegment`s.
local _ENTRY_MODE_START = Indicator.HighlightSegment.new(_HL_GROUP_PROMPT, '-- ')
local _ENTRY_MODE_END   = Indicator.HighlightSegment.new(_HL_GROUP_PROMPT, ' --')

-- `libmodal.prompt` `HighlightSegment`s.
local _ENTRY_PROMPT_START = Indicator.HighlightSegment.new(_HL_GROUP_STAR, '* ')
local _ENTRY_PROMPT_END   = Indicator.HighlightSegment.new(_HL_GROUP_PROMPT, ' > ')

--[[
	/*
	 * META `Indicator`
	 */
--]]

local _metaIndicator = {
	_ENTRY_MODE_START, nil, _ENTRY_MODE_END
}
_metaIndicator.__index = _metaIndicator

local _PROMPT_TEMPLATE = {
	'* ', ' > '
}

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
	local self = {}
	setmetatable(self, _metaIndicator)

	self[2] = Indicator.HighlightSegment.new(
		_HL_GROUP_PROMPT, tostring(modeName)
	)

	return self
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
	return table.concat(_PROMPT_TEMPLATE, modeName)
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return Indicator
