--[[
	/*
	 * IMPORTS
	 */
--]]

local globals = require('libmodal/src/globals')
local utils   = require('libmodal/src/utils')
local Vars    = require('libmodal/src/Vars')

local api  = utils.api

--[[
	/*
	 * MODULE
	 */
--]]

local Mode = {}

Mode.ParseTable = require('libmodal/src/mode/ParseTable')
Mode.Popup      = require('libmodal/src/Mode/Popup')

local _metaMode = {}

local _HELP = '?'
local _TIMEOUT = {
	['CHAR'] = 'ø',
	['LEN']  = api.nvim_get_option('timeoutlen'),
	['SEND'] = function(__self)
		api.nvim_feedkeys(__self.CHAR, '', false)
	end
}
_TIMEOUT.NR = string.byte(_TIMEOUT.CHAR)

--[[
	/*
	 * META `_metaMode`
	 */
--]]

-----------------------------------------------
--[[ SUMMARY:
	* Parse `self._mappings` and see if there is any command to execute.
]]
-----------------------------------------------
function _metaMode:_checkInputForMapping()
	-- Stop any running timers
	if self._flushInputTimer then
		self._flushInputTimer:stop()
	end

	-- Append the latest input to the locally stored input history.
	self._input.bytes[#self._input.bytes + 1] = self._input:nvimGet(self._name)

	-- Get the command based on the users input.
	local cmd = self._mappings:get(self._input.bytes)

	-- Get the type of the command.
	local commandType = type(cmd)
	local clearInputBytes = false

	-- if there was no matching command
	if cmd == false then
		if #self._input.bytes < 2 and self._input.bytes[1] == string.byte(_HELP) then
			self._help:show()
		end
		self._input:clear()
	-- The command was a table, meaning that it MIGHT match.
	elseif commandType == globals.TYPE_TBL
	       and globals.isTrue(self._timeouts.enabled)
	then
		-- Create a new timer

		-- start the timer
		self._flushInputTimer:start(
			_TIMEOUT.LEN, 0, vim.schedule_wrap(function()
				-- Send input to interrupt a blocking `getchar`
				_TIMEOUT:SEND()
				-- if there is a command, execute it.
				if cmd[Mode.ParseTable.CR] then
					api.nvim_command(cmd[Mode.ParseTable.CR])
				end
				-- clear input
				self._input:clear()
				self._popup:refresh(self._input.bytes)
			end)
		)
	-- The command was an actual vim command.
	else
		api.nvim_command(cmd)
		self._input:clear()
	end

	self._popup:refresh(self._input.bytes)
end

--------------------------
--[[ SUMMARY:
	* Enter `self`'s mode.
]]
--------------------------
function _metaMode:enter()
	if self._instruction == globals.TYPE_TBL then
		-- Create a timer
		self._flushInputTimer = vim.loop.new_timer()

		-- Initialize the input history variable.
		self._input = {
			['bytes'] = {},
			----------------------------
			--[[ SUMMARY:
				* Clear the self.bytes table.
			]]
			----------------------------
			['clear'] = function(__self)
				__self.bytes = {}
			end
		}

		-- create a floating window
		self._popup = Mode.Popup.new()
	end

	--[[ MODE LOOP. ]]
	local continueMode = true
	while continueMode == true do
		-- Try (using pcall) to use the mode.
		local noErrors, modeResult = pcall(self._inputLoop, self)

		-- If there were errors, handle them.
		if noErrors == false then
			utils.showError(modeResult)
			continueMode = false
		else
			continueMode = modeResult
		end
	end

	self:_tearDown()
end

----------------------------------
--[[ SUMMARY:
	* Set the initial values used for parsing user input as combos.
]]
----------------------------------
function _metaMode:_initMappings()
	-- Create a variable for whether or not timeouts are enabled.
	self._timeouts = Vars.new('timeouts')

	-- Read the correct timeout variable.
	if api.nvim_exists('g', self._timeouts:name(modeName)) then self._timeouts.enabled =
		self._timeouts:nvimGet(self._name)
	else self._timeouts.enabled =
		Vars.libmodalTimeouts
	end

	-- Determine if a default `Help` should be created.
	if not self._instruction[_HELP] then
		self._help = utils.Help.new(self._instruction, 'KEY MAP')
	end

	-- Build the parse tree.
	self._mappings = Mode.ParseTable.new(self._instruction)
end

------------------------------------
--[[ SUMMARY:
	* Loop an initialized `mode`.
]]
--[[ RETURNS:
	* `boolean` => whether or not the mode should continue
]]
------------------------------------
function _metaMode:_inputLoop()
	-- If the mode is not handling exit events automatically and the global exit var is true.
	if self._exit.supress
	   and globals.isTrue(self._exit:nvimGet(self._name))
	then
		return false
	end

	-- Echo the indicator.
	api.nvim_lecho(self._indicator)

	-- Capture input.
	local userInput = api.nvim_input()

	-- Return if there was a timeout event.
	if userInput == _TIMEOUT.NR then
		return true
	end

	-- Set the global input variable to the new input.
	self._input:nvimSet(self._name, userInput)

	-- Make sure that the user doesn't want to exit.
	if not self._exit.supress
	   and userInput == globals.ESC_NR then return false
	-- If the second argument was a dict, parse it.
	elseif type(self._instruction) == globals.TYPE_TBL then
		self:_checkInputForMapping()
	else -- the second argument was a function; execute it.
		self._instruction()
	end

	return true
end

---------------------------------
--[[ SUMMARY:
	* Remove variables used for a mode.
]]
---------------------------------
function _metaMode:_tearDown()
	if self._instruction == globals.TYPE_TBL then
		self._flushInputTimer:stop()
		self._flushInputTimer = nil

		for k, _ in pairs(self._input) do
			self._input[k] = nil
		end
		self._input = nil

		self._popup:close()
		self._popup = nil
	end

	self._winState:restore()
end

--[[
	/*
	 * CLASS `Mode`
	 */
--]]

------------------------
--[[ SUMMARY:
	* Enter a mode.
]]
--[[ PARAMS:
	* `name` => the mode name.
	* `instruction` => the mode callback, or mode combo table.
	* `...` => optional exit supresion flag.
]]
------------------------
-- TODO
function Mode.new(name, instruction, ...)
	-- Inherit the metatable.
	self = {}
	setmetatable(self, _metaMode)
	self.__index = self

	-- Define the exit flag
	self._exit         = Vars.new('exit')
	self._exit.supress = (function(optionalValue)
		if #optionalValue > 0 then
			return globals.isTrue(optionalValue)
		else
			return false
		end
	end)(unpack({...}))

	-- Define other "session" variables.
	self._indicator   = utils.Indicator.mode(name)
	self._instruction = instruction
	self._name        = name
	self._winState    = utils.WindowState.new()

	-- Determine whether a callback was specified, or a combo table.
	if type(instruction) == globals.TYPE_TBL then
		self:_initMappings()
	end

	return self
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return Mode
