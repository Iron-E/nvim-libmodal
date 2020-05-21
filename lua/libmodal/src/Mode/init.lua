--[[
	/*
	 * IMPORTS
	 */
--]]

local globals     = require('libmodal/src/globals')
local Indicator   = require('libmodal/src/Indicator')
local collections = require('libmodal/src/collections')
local utils       = require('libmodal/src/utils')
local Vars        = require('libmodal/src/Vars')

local api  = utils.api

--[[
	/*
	 * MODULE
	 */
--]]

local Mode = {}

Mode.Popup      = require('libmodal/src/Mode/Popup')

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

local _metaMode = {}
_metaMode.__index = _metaMode

local _metaInputBytes = {
	['clear'] = function(__self)
		for i, _ in ipairs(__self) do
			__self[i] = nil
		end
	end
}
_metaInputBytes.__index = _metaInputBytes


-----------------------------------------------
--[[ SUMMARY:
	* Parse `self._mappings` and see if there is any command to execute.
]]
-----------------------------------------------
function _metaMode:_checkInputForMapping()
	-- Stop any running timers
	self._flushInputTimer:stop()

	-- Append the latest input to the locally stored input history.
	local inputBytes = self._inputBytes

	inputBytes[#inputBytes + 1] = self._input:nvimGet()

	-- Get the command based on the users input.
	local cmd = self._mappings:get(inputBytes)

	-- Get the type of the command.
	local commandType = type(cmd)
	local clearInputBytes = false

	-- if there was no matching command
	if cmd == false then
		if #inputBytes < 2 and inputBytes[1] == string.byte(_HELP) then
			self._help:show()
		end
		inputBytes:clear()
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
				if cmd[collections.ParseTable.CR] then
					api.nvim_command(cmd[collections.ParseTable.CR])
				end
				-- clear input
				inputBytes:clear()
				self._popups:peek():refresh(inputBytes)
			end)
		)

	-- The command was an actual vim command.
	else
		api.nvim_command(cmd)
		inputBytes:clear()
	end

	self._popups:peek():refresh(inputBytes)
end

--------------------------
--[[ SUMMARY:
	* Enter `self`'s mode.
]]
--------------------------
function _metaMode:enter()
	-- intialize variables that are needed for each recurse of a function
	if type(self._instruction) == globals.TYPE_TBL then
		-- Initialize the input history variable.
		self._popups:push(Mode.Popup.new())
	end


	--[[ MODE LOOP. ]]
	local continueMode = true
	while continueMode do
		-- Try (using pcall) to use the mode.
		local noErrors, modeResult = pcall(self._inputLoop, self)

		-- If there were errors, handle them.
		if not noErrors then
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
	-- Create a timer to perform actions with.
	self._flushInputTimer = vim.loop.new_timer()

	-- Determine if a default `Help` should be created.
	if not self._instruction[_HELP] then
		self._help = utils.Help.new(self._instruction, 'KEY MAP')
	end

	self._inputBytes = setmetatable({}, _metaInputBytes)

	-- Build the parse tree.
	self._mappings = collections.ParseTable.new(self._instruction)

	-- Create a table for mode-specific data.
	self._popups = collections.Stack.new()

	-- Create a variable for whether or not timeouts are enabled.
	self._timeouts = Vars.new('timeouts', self._name)

	-- Read the correct timeout variable.
	if api.nvim_exists('g', self._timeouts:name())
	then self._timeouts.enabled =
		self._timeouts:nvimGet()
	else self._timeouts.enabled =
		Vars.libmodalTimeouts
	end
end

-------------------------------
--[[ SUMMARY:
	* Loop an initialized `mode`.
]]
--[[ RETURNS:
	* `boolean` => whether or not the mode should continue
]]
-------------------------------
function _metaMode:_inputLoop()
	-- If the mode is not handling exit events automatically and the global exit var is true.
	if self._exit.supress
	   and globals.isTrue(self._exit:nvimGet())
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
	self._input:nvimSet(userInput)

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

------------------------------
--[[ SUMMARY:
	* Remove variables used for a mode.
]]
------------------------------
function _metaMode:_tearDown()
	if type(self._instruction) == globals.TYPE_TBL then
		self._flushInputTimer:stop()
		self._inputBytes = nil

		self._popups:pop():close()
	end

	self._winState:restore()
	api.nvim_redraw()
end

--[[
	/*
	 * CLASS `Mode`
	 */
--]]

-----------------------------------------
--[[ SUMMARY:
	* Enter a mode.
]]
--[[ PARAMS:
	* `name` => the mode name.
	* `instruction` => the mode callback, or mode combo table.
	* `...` => optional exit supresion flag.
]]
-----------------------------------------
function Mode.new(name, instruction, ...)
	-- Inherit the metatable.
	local self = setmetatable(
		{
			['_exit']        = Vars.new('exit', name),
			['_indicator']   = Indicator.mode(name),
			['_input']       = Vars.new('input', name),
			['_instruction'] = instruction,
			['_name']        = name,
			['_winState']    = utils.WindowState.new(),
		},
		_metaMode
	)

	-- Define the exit flag
	self._exit.supress = (function(optionalValue)
		if optionalValue then
			return globals.isTrue(optionalValue)
		else
			return false
		end
	end)(unpack({...}))

	-- Define other "session" variables.

	-- Determine whether a callback was specified, or a combo table.
	if type(instruction) == globals.TYPE_TBL then
		self:_initMappings()
	end

	return self
end

--[[
	/
	 * PUBLICIZE MODULE
	 */
--]]

return Mode
