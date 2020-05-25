--[[
	/*
	 * IMPORTS
	 */
--]]

local classes = require('libmodal/src/classes')
local globals = require('libmodal/src/globals')
local Mode    = require('libmodal/src/Mode')

--[[
	/*
	 * MODULE
	 */
--]]

local ModeLayer = {['TYPE'] = 'libmodal-mode-layer'}

--[[
	/*
	 * META `ModeLayer`
	 */
--]]

local _metaModeLayer = classes.new(ModeLayer.TYPE)

-------------------------------
--[[ SUMMARY:
	* Enter the `ModeLayer`, replacing any conflicting mappings.
]]
-------------------------------
function _metaModeLayer:enter()
	-- Create aliases.
	local layerMode        = self._mode
	local layerInstruction = self._instruction

	-- Create a new `priorInstruction`.
	local priorInstruction = nil

	if self._isTable then -- the layer is a table
		local modeInstruction = mode._instruction
		priorInstruction = {}

		for keys, mapping in pairs(layerInstruction) do
			priorInstruction[keys] = modeInstruction:parseGet(keys)
			modeInstruction:parsePut(keys, mapping)
		end
	else -- the layer is a function
		priorInstruction  = layerMode._instruction
		mode._instruction = layerInstruction
	end

	self._priorInstruction = priorInstruction
end

-------------------------------
--[[ SUMMARY:
	* Exit the `ModeLayer`, and restore any overwritten mappings.
]]
-------------------------------
function _metaModeLayer:exit()
	if self._isTable then
		local modeInstruction  = self._mode._instruction

		for keys, mapping in pairs(self._priorInstruction) do
			modeInstruction:parsePut(keys, mapping)
		end
	else
		self._mode._instruction = self._priorInstruction
	end

	self._priorInstruction = nil
end

--[[
	/*
	 * CLASS `ModeLayer`
	 */
--]]

-----------------------------------------
--[[ SUMMARY:
	* Create a new `ModeLayer`.
]]
-----------------------------------------
function ModeLayer.new(mode, instruction)
	if classes.type(mode) == Mode.TYPE
		and type(mode._instruction) == type(instruction)
	then
		return setmetatable(
			{
				['_isTable'] = type(instruction) == globals.TYPE_TBL,
				['_instruction'] = instruction,
				['_mode']        = mode
			}, _metaModeLayer
		)
	else
		error('Either `mode` is not a `Mode`, '
			.. 'or `instruction` is not the same type '
			.. 'as it was when `mode` was created.'
		)
	end
end
