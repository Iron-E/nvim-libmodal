--[[
	/*
	 * IMPORTS
	 */
--]]

local classes = require('libmodal/src/classes')

--[[
	/*
	 * MODULE
	 */
--]]

local PromptLayer = {['TYPE'] = 'libmodal-prompt-layer'}

--[[
	/*
	 * META `PromptLayer`
	 */
--]]

local _metaPromptLayer = classes.new(PromptLayer.TYPE)

-------------------------------
--[[ SUMMARY:
	* Enter the `PromptLayer`, replacing any conflicting executes.
]]
-------------------------------
function _metaPromptLayer:enter()
	-- Create aliases.
	local layerPrompt      = self._prompt
	local layerInstruction = self._instruction

	-- Create a new `priorInstruction`.
	local priorInstruction = nil

	if self._isTable then -- the layer is a table
		local promptInstruction = prompt._instruction
		priorInstruction = {}

		for command, execute in pairs(layerInstruction) do
			priorInstruction[command] = promptInstruction[command]
			promptInstruction[command]  = execute
		end
	else -- the layer is a function
		priorInstruction  = layerPrompt._instruction
		prompt._instruction = layerInstruction
	end

	self._priorInstruction = priorInstruction
end

-------------------------------
--[[ SUMMARY:
	* Exit the `PromptLayer`, and restore any overwritten executes.
]]
-------------------------------
function _metaPromptLayer:exit()
	if self._isTable then
		local promptInstruction  = self._prompt._instruction

		for command, execute in pairs(self._priorInstruction) do
			promptInstruction[command] = execute
		end
	else
		self._prompt._instruction = self._priorInstruction
	end

	self._priorInstruction = nil
end

--[[
	/*
	 * CLASS `PromptLayer`
	 */
--]]

-----------------------------------------
--[[ SUMMARY:
	* Create a new `PromptLayer`.
]]
-----------------------------------------
function PromptLayer.new(prompt, instruction)
	if classes.type(prompt) == require('libmodal/src/Prompt').TYPE
		and type(prompt._instruction) == type(instruction)
	then
		return setmetatable(
			{
				['_isTable'] = type(instruction) == require('libmodal/src/globals').TYPE_TBL,
				['_instruction'] = instruction,
				['_prompt']        = prompt
			}, _metaPromptLayer
		)
	else
		error('Either `prompt` is not a `Prompt`, '
			.. 'or `instruction` is not the same type '
			.. 'as it was when `prompt` was created.'
		)
	end
end
