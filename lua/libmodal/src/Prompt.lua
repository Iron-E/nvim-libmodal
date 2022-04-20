--[[/* IMPORTS */]]

local globals   = require('libmodal/src/globals')
local utils     = require('libmodal/src/utils')
local Vars      = require('libmodal/src/Vars')

--[[/* MODULE */]]

local Prompt = {TYPE = 'libmodal-prompt'}

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

---------------------------------------------------
--[[ SUMMARY:
	* Execute the specified instruction based on user input.
]]
--[[ PARAMS:
	* `userInput` => the input from the user, used to determine how to execute the `self._instruction`.
]]
---------------------------------------------------
function _metaPrompt:_executeInstruction(userInput)
	-- get the instruction for the mode.
	local instruction = self._instruction

	if type(instruction) == globals.TYPE_TBL then -- The instruction is a command table.
		if instruction[userInput] then -- There is a defined command for the input.
			local to_execute = instruction[userInput]
			if type(to_execute) == globals.TYPE_FUNC then
				to_execute()
			else
				vim.api.nvim_command(instruction[userInput])
			end
		elseif userInput == _HELP then -- The user did not define a 'help' command, so use the default.
			self._help:show()
		else -- show an error.
			utils.api.nvim_show_err(globals.DEFAULT_ERROR_TITLE, 'Unknown command')
		end
	elseif type(instruction) == globals.TYPE_STR then -- The instruction is a function.
		vim.fn[instruction]()
	else -- attempt to call the instruction.
		instruction()
	end
end

---------------------------------
--[[ SUMMARY:
	* Loop to get user input with `input()`.
]]
---------------------------------
function _metaPrompt:_inputLoop()
	-- If the mode is not handling exit events automatically and the global exit var is true.
	if self.exit.supress and globals.is_true(self.exit:nvimGet()) then
		return false
	end

	-- clear previous `echo`s.
	utils.api.nvim_redraw()

	-- determine what to do with the input
	local function userInputCallback(userInput)
		if userInput and string.len(userInput) > 0 then -- The user actually entered something.
			self.input:nvimSet(userInput)
			self:_executeInstruction(userInput)
		else -- indicate we want to leave the prompt
			return false
		end

		return true
	end

	-- echo the highlighting
	vim.api.nvim_command('echohl ' .. self.indicator.hl)

	-- set the user input variable
	if self._completions then
		vim.api.nvim_command('echo "' .. self.indicator.str .. '"')
		return vim.ui.select(self._completions, {}, userInputCallback)
	else
		return vim.ui.input({prompt = self.indicator.str}, userInputCallback)
	end
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
			continueMode = true
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
			exit         = Vars.new('exit', name),
			indicator    = require('libmodal/src/Indicator').prompt(name),
			input        = require('libmodal/src/Vars').new('input', name),
			_instruction = instruction,
			_name        = name
		},
		_metaPrompt
	)

	-- get the arguments
	local userCompletions, supressExit = unpack({...})

	self.exit.supress = supressExit or false

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
