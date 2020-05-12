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
			spacedArgLead = string.gsub(spacedArgLead, v, ' ')
		end

		-- split the spaced version of `argLead`.
		local splitArgLead = utils.strings.split(splitArgLead, ' ')

		-- make sure the user is in a position were this function
		--     will provide accurate completions.
		if #splitArgLead > 1 then return nil end

		-- get the word selected by the user.
		local word = splitArgLead[1]

		-- get all matches from the completions list.
		local matches = {}
		local i = 1
		for _, v in ipairs(completions) do
			if string.match(word, completion) then
				matches[i] = completion
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
	elseif #args > 2 then completions = args[3] end

	-- make the completions dict vim-compatable
	if completions then completions =
		'[' .. table.concat(completions, ',') .. ']'
	end

	local continueMode = true
	while continueMode == true do
		local noErrors, err = pcall(function()
			-- echo the indicator
			api.nvim_redraw()

			-- compose prompt command
			--[[ TODO: completions won't work until neovim 0.5
					   look into v:lua when it drops.

				local cmd = "input('" .. indicator .. "', ''"
				if completions then cmd =
					cmd .. ", 'customlist,funcref(\"libmodal#CreateCompletionsProvider\", ["
						.. completions ..
					"])'"
				end
				-- get input from prompt
				local uinput = api.nvim_eval(cmd .. ')') -- closing bracket ends beginning 'input('
			--]]

			local uinput = api.nvim_call_function('input', {indicator})

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
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return prompt
