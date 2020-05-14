--[[
	/*
	 * IMPORTS
	 */
--]]

local globals = require('libmodal/src/base/globals')
local utils   = require('libmodal/src/utils')

local api  = utils.api
local vars = utils.vars

--[[
	/*
	 * MODULE
	 */
--]]

local prompt = {}

--[[
	/*
	 * LIB `prompt`
	 */
--]]

local _HELP = 'help'

local _replacements = {
	'(', ')', '[', ']', '{', '}',
	'=', '+', '<', '>', '^',
	',', '/', ':', '?', '@', '!', '$', '*', '.', '%', '&', '\\',
}

-------------------------------------------------------
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
-------------------------------------------------------
function prompt._createCompletionsProvider(completions)
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


--------------------------
--[[ SUMMARY:
	* Enter a prompt.
]]
--[[ PARAMS:
	* `args[1]` => the prompt name.
	* `args[2]` => the prompt callback, or mode command table.
	* `args[3]` => a completions table.
]]
--------------------------
function prompt.enter(...)
	-- get the arguments
	local args = {...}

	-- create an indicator
	local indicator = utils.Indicator.prompt(args[1])

	-- lowercase of the passed mode name.
	local modeName = string.lower(args[1])

	-- get the completion list.
	local completions = nil
	if type(args[2]) == globals.TYPE_TBL then -- unload the keys of the mode command table.
		completions = {}
		local containedHelp = false
		for k, _ in pairs(args[2]) do
			completions[#completions + 1] = k
			if k == _HELP then containedHelp = true
			end
		end
		if not containedHelp then -- assign it.
			completions[#completions + 1] = _HELP
		end
	elseif #args > 2 then -- assign completions as the custom completions table provided.
		completions = args[3]
	end


	-- enter the mode using a loop.
	local continueMode =  true
	while continueMode == true do
		local noErrors, err = pcall(function()
			-- clear previous `echo`s.
			api.nvim_redraw()

			-- get user input based on `args[2]`.
			local userInput = ''
			if completions then userInput =
				api.nvim_call_function('libmodal#_inputWith', {indicator, completions})
			else userInput =
				api.nvim_call_function('input', {indicator})
			end

			-- if a:2 is a function then call it.
			if string.len(userInput) > 0 then
				vars.nvim_set(vars.input, modeName, userInput)
				if type(args[2]) == globals.TYPE_TBL then
					if args[2][userInput] then -- there is a defined command for the input.
						api.nvim_command(args[2][userInput])
					elseif userInput == _HELP then -- the user did not define a 'help' command, so use the default.
						utils.commandHelp(args[2])
					else -- show an error.
						api.nvim_show_err(globals.DEFAULT_ERROR_MESSAGE, 'Unknown command')
					end
				else
					args[2]()
				end
			else
				continueMode = false
			end
		end)

		-- if there were errors.
		if noErrors == false then
			utils.showError(err)
			continueMode = false
		end
	end

	-- delete temporary variables created for this mode.
	vars:tearDown(modeName)
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return prompt
