--[[
	/*
	 * IMPORTS
	 */
--]]

local globals   = require('libmodal/src/globals')
local Indicator = require('libmodal/src/Indicator')
local Stack     = require('libmodal/src/collections/Stack')
local utils     = require('libmodal/src/utils')
local Vars      = require('libmodal/src/Vars')

local api  = utils.api

--[[
	/*
	 * MODULE
	 */
--]]

local Prompt = {}

local _HELP = 'help'
local _replacements = {
	'(', ')', '[', ']', '{', '}',
	'=', '+', '<', '>', '^',
	',', '/', ':', '?', '@', '!', '$', '*', '.', '%', '&', '\\',
}

--[[
	/*
	 * META `Prompt`
	 */
--]]

local _metaPrompt = {}
_metaPrompt.__index = _metaPrompt

_metaPrompt._indicator   = nil
_metaPrompt._input       = nil
_metaPrompt._instruction = nil
_metaPrompt._name        = nil

function _metaPrompt:_inputLoop()
	-- clear previous `echo`s.
	api.nvim_redraw()

	-- get user input based on `instruction`.
	local userInput = ''
	if self._completions then userInput =
		api.nvim_call_function('libmodal#_inputWith', {
			self._indicator, self._completions
		})
	else userInput =
		api.nvim_call_function('input', {
			self._indicator
		})
	end

	-- if a:2 is a function then call it.
	if string.len(userInput) > 0 then
		self._input:nvimSet(self._name, userInput)
		if type(self._instruction) == globals.TYPE_TBL then
			if self._instruction[userInput] then -- there is a defined command for the input.
				api.nvim_command(instruction[userInput])
			elseif userInput == _HELP then -- the user did not define a 'help' command, so use the default.
				self._help:show()
			else -- show an error.
				api.nvim_show_err(globals.DEFAULT_ERROR_TITLE, 'Unknown command')
			end
		else instruction()
		end
	else return false
	end

	return true
end

function _metaPrompt:enter()
	-- enter the mode using a loop.
	local continueMode =  true
	while continueMode == true do
		local noErrors, result = pcall(self._inputLoop, self)

		-- if there were errors.
		if not noErrors then
			utils.showError(err)
			continueMode = false
		else
			continueMode = result
		end
	end
end

--[[
	/*
	 * CLASS `Prompt`
	 */
--]]

------------------------------------------------------
--[[ SUMMARY:
	* Provide completions for a `libmodal.prompt`.
]]
--[[ PARAMS:
	* `completions` => the list of completions.
]]
--[[ RETURNS:
	* A function that accepts:
		* `argLead` => the current line being edited, stops at the cursor.
		* `cmdLine` => the current line being edited
		* `cursorPos` => the position of the cursor
	* Used for `input()` VimL.
]]
------------------------------------------------------
function Prompt.createCompletionsProvider(completions)
	return function(argLead, cmdLine, cursorPos)
		if string.len(cmdLine) < 1 then
			return completions
		end

		-- replace conjoining characters with spaces.
		local spacedArgLead = argLead
		for _, v in ipairs(_replacements) do
			spacedArgLead, _ = string.gsub(spacedArgLead, vim.pesc(v), ' ')
		end

		-- split the spaced version of `argLead`.
		local splitArgLead = vim.split(spacedArgLead, ' ', true)

		-- make sure the user is in a position were this function
		--     will provide accurate completions.
		if #splitArgLead > 1 then
			return nil
		end

		-- get the word selected by the user. (don't compare case)
		local word = string.upper(splitArgLead[1])

		-- get all matches from the completions list.
		local matches = {}
		for _, v in ipairs(completions) do
			-- test if `word` is inside of `completions`:`v`, ignoring case.
			if string.match(vim.pesc(string.upper(v)), word) then
				matches[#matches + 1] = v -- preserve case when providing completions.
			end
		end
		return matches
	end
end

-------------------------------------------
--[[ SUMMARY:
	* Enter a prompt.
]]
--[[ PARAMS:
	* `name` => the prompt name.
	* `instruction` => the prompt callback, or mode command table.
	* `...` => a completions table.
]]
-------------------------------------------
function Prompt.new(name, instruction, ...)
	self = setmetatable({}, _metaPrompt)

	self._indicator   = Indicator.prompt(name)
	self._input       = vars.new('input')
	self._instruction = instruction
	self._name        = name

	-- get the arguments
	local userCompletions = unpack({...})

	-- get the completion list.
	if type(instruction) == globals.TYPE_TBL then -- unload the keys of the mode command table.
		-- Create one if the user specified a command table.
		local completions   = {}
		local containedHelp = false

		for k, _ in pairs(instruction) do
			completions[#completions + 1] = k
			if k == _HELP then containedHelp = true
			end
		end

		if not containedHelp then -- assign it.
			completions[#completions + 1] = _HELP
			vars.help.instances[modeName] = utils.Help.new(instruction, 'COMMAND')
		end

		self._completions = completions
	elseif userCompletions then
		-- Use the table that the user gave.
		self._completions = userCompletions
	end
end


--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return Prompt
