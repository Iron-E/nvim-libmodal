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
			local cmd = "input('" .. indicator .. "', ''"
			if completions then cmd =
				cmd .. ", 'customlist,funcref(\"libmodal#CreateCompletionsProvider\", ["
					.. completions ..
				"])'"
			end

			-- get input from prompt
			local uinput = api.nvim_eval(cmd .. ')') -- closing bracket ends beginning 'input('

			-- if a:2 is a function then call it.
			if string.len(uinput) > 0 then
				vars.nvim_set(vars.input, modeName, uinput)
				if completions then
					if args[2][uinput] then
						api.nvim_command(args[2][uinput])
					else
						api.nvim_show_err('Unknown command.')
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
