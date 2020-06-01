--[[
	/*
	 * IMPORTS
	 */
--]]

local globals   = require('libmodal/src/globals')
local utils     = require('libmodal/src/utils')

local api  = utils.api

--[[
	/*
	 * MODULE
	 */
--]]

local Prompt = {['TYPE'] = 'libmodal-prompt'}

local _HELP = 'help'
local _REPLACEMENTS = {
	'(', ')', '[', ']', '{', '}',
	'=', '+', '<', '>', '^',
	',', '/', ':', '?', '@', '!', '$', '*', '.', '%', '&', '\\',
}
for i, replacement in ipairs(_REPLACEMENTS) do
	_REPLACEMENTS[i], _ = vim.pesc(replacement)
end

--[[
	/*
	 * META `Prompt`
	 */
--]]

local _metaPrompt = require('libmodal/src/classes').new(Prompt.TYPE)

---------------------------------
--[[ SUMMARY:
	* Loop to get user input with `input()`.
]]
---------------------------------
function _metaPrompt:_inputLoop()
	-- clear previous `echo`s.
	api.nvim_redraw()

	-- define a placeholder for user input
	local userInput = ''

	-- echo the highlighting
	api.nvim_command('echohl ' .. self.indicator.hl)

	-- set the user input variable
	if self._completions
	then userInput =
		api.nvim_call_function('libmodal#_inputWith', {
			self.indicator.str, self._completions
		})
	else userInput =
		api.nvim_call_function('input', {self.indicator})
	end

	-- get the instruction for the mode.
	local instruction = self._instruction

	-- determine what to do with the input
	if string.len(userInput) > 0 then -- the user actually entered something
		self.input:nvimSet(userInput)
		if type(instruction) == globals.TYPE_TBL then -- the instruction is a command table.
			if instruction[userInput] then -- there is a defined command for the input.
				api.nvim_command(instruction[userInput])
			elseif userInput == _HELP then -- the user did not define a 'help' command, so use the default.
				self._help:show()
			else -- show an error.
				api.nvim_show_err(globals.DEFAULT_ERROR_TITLE, 'Unknown command')
			end
		else -- attempt to call the instruction.
			instruction()
		end
	else -- indicate we want to leave the prompt
		return false
	end

	return true
end

----------------------------
--[[ SUMMARY:
	* Enter a prompt 'mode'.
]]
----------------------------
function _metaPrompt:enter()
	-- enter the mode using a loop.
	local continueMode = true
	while continueMode do
		local noErrors, promptResult = pcall(self._inputLoop, self)

		-- if there were errors.
		if not noErrors then
			utils.show_error(promptResult)
			continueMode = false
		else
			continueMode = promptResult
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
		if string.len(cmdLine) < 1 then return completions
		end

		-- replace conjoining characters with spaces.
		local spacedArgLead = argLead
		for _, replacement in ipairs(_REPLACEMENTS) do
			-- _REPLACEMENTS are already `vim.pesc`aped
			spacedArgLead, _ = string.gsub(spacedArgLead, replacement, ' ')
		end

		-- split the spaced version of `argLead`.
		local splitArgLead = vim.split(spacedArgLead, ' ', true)

		--[[ make sure the user is in a position were this function
		     will provide accurate completions.]]
		if #splitArgLead > 1 then return nil
		end

		-- get the word selected by the user. (don't compare case)
		local word = string.upper(splitArgLead[1])

		-- get all matches from the completions list.
		local matches = {}
		for _, completion in ipairs(completions) do
			-- test if `word` is inside of `completions`:`v`, ignoring case.
			local escapedCompletion, _ = vim.pesc(string.upper(completion))
			if string.match(escapedCompletion, word) then
				matches[#matches + 1] = completion -- preserve case when providing completions.
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
	name = vim.trim(name)

	local self = setmetatable(
		{
			['indicator']    = require('libmodal/src/Indicator').prompt(name),
			['input']        = require('libmodal/src/Vars').new('input', name),
			['_instruction'] = instruction,
			['_name']        = name
		},
		_metaPrompt
	)

	-- get the arguments
	local userCompletions = unpack({...})

	-- get the completion list.
	if type(instruction) == globals.TYPE_TBL then -- unload the keys of the mode command table.
		-- Create one if the user specified a command table.
		local completions   = {}
		local containedHelp = false

		for command, _ in pairs(instruction) do
			completions[#completions + 1] = command
			if command == _HELP then containedHelp = true
			end
		end

		if not containedHelp then -- assign it.
			completions[#completions + 1] = _HELP
			self._help = utils.Help.new(instruction, 'COMMAND')
		end

		self._completions = completions
	elseif userCompletions then
		-- Use the table that the user gave.
		self._completions = userCompletions
	end

	return self
end


--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return Prompt
