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

-- highlight group names
local _HL_GROUP_PROMPT = 'LibmodalPrompt'
local _HL_GROUP_STAR = 'LibmodalStar'
local _HL_GROUP_NONE = 'None'

-- `libmodal.mode` `Entry`s.
local _ENTRY_MODE_START = Entry.new(_HL_GROUP_PROMPT, '-- ')
local _ENTRY_MODE_END = Entry.new(_HL_GROUP_PROMPT, ' --')

-- `libmodal.prompt` `Entry`s.
local _ENTRY_PROMPT_START = Entry.new(_HL_GROUP_STAR, '* ')
local _ENTRY_PROMPT_END = Entry.new(_HL_GROUP_PROMPT, ' > ')

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
		_ENTRY_MODE_START,
		Entry.new(_HL_GROUP_PROMPT, tostring(modeName)),
		_ENTRY_MODE_END
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
	return '* ' .. tostring(modeName) .. ' > '
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return Indicator
