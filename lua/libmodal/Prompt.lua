local utils = require 'libmodal.utils' --- @type libmodal.utils

--- @class libmodal.Prompt
--- @field private completions? string[]
--- @field private indicator {hl: string, text: string}
--- @field private exit libmodal.utils.Var
--- @field private help? libmodal.utils.Help
--- @field private input libmodal.utils.Var
--- @field private instruction fun()|{[string]: fun()|string}
--- @field private name string
local Prompt = utils.classes.new()

local HELP = 'help'
local REPLACEMENTS =
{
	'(', ')', '[', ']', '{', '}',
	'=', '+', '<', '>', '^',
	',', '/', ':', '?', '@', '!', '$', '*', '.', '%', '&', '\\',
}

for i, replacement in ipairs(REPLACEMENTS) do
	REPLACEMENTS[i], _ = vim.pesc(replacement)
end

--- execute the instruction specified by the `user_input`.
--- @param user_input string
--- @return nil
function Prompt:execute_instruction(user_input)
	if type(self.instruction) == 'table' then -- the self.instruction is a command table.
		if self.instruction[user_input] then -- there is a defined command for the input.
			local to_execute = self.instruction[user_input]
			if type(to_execute) == 'function' then
				to_execute()
			else
				vim.api.nvim_command(to_execute)
			end
		elseif user_input == HELP then -- the user did not define a 'help' command, so use the default.
			self.help:show()
		else -- show an error.
			vim.notify('nvim-libmodal prompt: unkown command', vim.log.levels.ERROR, {title = 'nvim-libmodal'})
		end
	elseif type(self.instruction) == 'string' then -- the self.instruction is a function.
		vim.fn[self.instruction]()
	else -- attempt to call the self.instruction.
		self.instruction()
	end
end

--- get more input from the user.
--- @return boolean more_input
function Prompt:get_user_input()
	-- clear previous `echo`s.
	utils.api.redraw()

	local continue_prompt -- will set to true `true` if looping this prompt again

	--- 1. Set `g:<mode_name>ModeInput` to `user_input`
	--- 2. Execute any commands indicated by `user_input`
	--- 3. Read `g:<mode_name>ModeExit` to see if we should `continue_prompt`
	--- @param user_input string
	local function user_input_callback(user_input)
		if user_input and user_input:len() > 0 then -- the user actually entered something.
			self.input:set(user_input)
			self:execute_instruction(user_input)

			local should_exit = self.exit:get()
			if should_exit ~= nil then
				continue_prompt = not should_exit
			end
		else -- the user entered nothing.
			continue_prompt = false
		end
	end

	-- set the user input variable
	if self.completions then
		vim.api.nvim_echo({{self.indicator.text, self.indicator.hl}}, false, {})
		vim.ui.select(self.completions, {}, user_input_callback)
	else
		vim.api.nvim_command('echohl ' .. self.indicator.hl)
		vim.ui.input({prompt = self.indicator.text}, user_input_callback)
	end

	return continue_prompt == nil and true or continue_prompt
end

--- enter the prompt.
--- @return nil
function Prompt:enter()
	-- enter the mode using a loop.
	local continue_mode = true
	while continue_mode do
		local ok, prompt_result = pcall(self.get_user_input, self)

		-- if there were errors.
		if not ok then
			--- @diagnostic disable-next-line:param-type-mismatch if `not ok` then `mode_result` is a string
			utils.notify_error('Error during nvim-libmodal mode', prompt_result)
			continue_mode = false
		else
			continue_mode = prompt_result
		end
	end
end

--- enter a prompt.
--- @param name string the name of the prompt
--- @param instruction fun()|{[string]: fun()|string} what to do with user input
--- @param user_completions? string[] a list of possible inputs, provided by the user
--- @return libmodal.Prompt
function Prompt.new(name, instruction, user_completions)
	name = vim.trim(name)

	local self = setmetatable(
		{
			exit = utils.Var.new(name, 'exit'),
			indicator = {hl = 'LibmodalStar', text = '* ' .. name .. ' > '},
			input = utils.Var.new(name, 'input'),
			instruction = instruction,
			name = name
		},
		Prompt
	)

	-- get the completion list.
	if type(instruction) == 'table' then -- unload the keys of the mode command table.
		-- create one if the user specified a command table.
		local completions   = {}
		local contained_help = false

		--- @diagnostic disable-next-line:param-type-mismatch we check `instruction` is `table`
		for command, _ in pairs(instruction) do
			table.insert(completions, command)
			if command == HELP then
				contained_help = true
			end
		end

		if not contained_help then -- assign it.
			table.insert(completions, HELP)
			--- @diagnostic disable-next-line:param-type-mismatch we checked that `instruction` is a table above
			self.help = utils.Help.new(instruction, 'COMMAND')
		end

		self.completions = completions
	elseif user_completions then
		-- use the table that the user gave.
		self.completions = user_completions
	end

	return self
end

return Prompt
