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

		-- get the word selected by the user.
		local word = splitArgLead[1]

		-- get all matches from the completions list.
		local matches = {}
		local i = 1
		for _, v in ipairs(completions) do
			if string.match(vim.pesc(v), word) then
				matches[i] = v
				i = i + 1
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

	local modeName = string.lower(args[1])

	-- get the completion list.
	local completions = nil
	if type(args[2]) == globals.TYPE_TBL then
		-- unload the keys of the mode command table.
		completions = {}
		local i = 1
		for k, _ in pairs(args[2]) do
			completions[i] = k
			i = i + 1
		end
	-- assign completions as the custom completions table provided.
	elseif #args > 2 then
		completions = args[3]
	end

	local continueMode = true
	while continueMode == true do
		local noErrors, err = pcall(function()
			-- echo the indicator
			api.nvim_redraw()

			local uinput = ''
			if completions then
				uinput = api.nvim_call_function(
					'libmodal#_inputWith', {indicator, completions}
				)
			else
				uinput = api.nvim_call_function('input', {indicator})
			end

			-- if a:2 is a function then call it.
			if string.len(uinput) > 0 then
				vars.nvim_set(vars.input, modeName, uinput)
				if type(args[2]) == globals.TYPE_TBL then
					if args[2][uinput] then
						api.nvim_command(args[2][uinput])
					else
						api.nvim_show_err(globals.DEFAULT_ERROR_MESSAGE, 'Unknown command')
					end
				else
					args[2]()
				end
			else
				continueMode = false
			end
		end)

		if noErrors == false then
			utils.showError(err)
			continueMode = false
		end
	end

	vars:tearDown(modeName)
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return prompt
