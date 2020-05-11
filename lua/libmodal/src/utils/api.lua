--[[
	/*
	 * IMPORTS
	 */
--]]

local globals = require('libmodal/src/base/globals')
local Entry = require('libmodal/src/utils/Indicator/Entry')

--[[
	/*
	 * MODULE
	 */
--]]

local api = vim.api

------------------------
--[[ SUMMARY:
	* Make vim ring the visual/audio bell, if it is enabled.
]]
------------------------
function api.nvim_bell()
	api.nvim_command('normal ' .. string.char(27)) -- escape char
end

---------------------------
--[[ SUMMARY:
	* Echo a string to Vim.
]]
--[[ PARAMS:
	* `str` => the string to echo.
]]
---------------------------
function api.nvim_echo(str)
	api.nvim_command("echo " .. tostring(str))
end

-----------------------------------
--[[ SUMMARY:
	* Check whether or not some variable exists.
]]
--[[ PARAMS:
	* `scope` => The scope of the variable (i.e. `g`, `l`, etc.)
	* `var` => the variable to check for.
]]
-----------------------------------
function api.nvim_exists(scope, var)
	return api.nvim_eval("exists('" .. scope .. ":" .. var .. "')") == globals.VIM_TRUE
end

-------------------------
--[[ SUMMARY:
	* Gets one character of user input, as a number.
]]
--[[ REMARKS:
	* This could also be:
	```lua
	local cmd = {
		'"while 1"',
			'"let c = getchar(0)"',
			'"if empty(c)"',
				'"sleep 20m"',
			'"else"',
				'"echo c"',
				'"break"',
			'"endif"',
		'"endwhile"'
	}

	return tonumber(vim.api.nvim_eval(
		"execute([" ..  table.concat(cmd, ',') .. "])"
	))
	```
	However, I'm not sure if it would accidentally affect text.
]]
-------------------------
function api.nvim_input()
	return api.nvim_eval('getchar()')
end

---------------------------------
--[[ SUMMARY:
	* Echo a table of {`hlgroup`, `str`} tables.
	* Meant to be read as "nvim list echo".
]]
--[[ PARAMS:
	* `hlTables` => the tables to echo with highlights.
]]
---------------------------------
local resetHighlight = Entry.new('None', '')
function api.nvim_lecho(hlTables)
	api.nvim_redraw()
	table.insert(hlTables, resetHighlight)
	for _, hlTable in ipairs(hlTables) do
		api.nvim_command(
			-- `:echohl` the hlgroup and then `:echon` the string.
			"echohl " .. hlTable.hl .. " | echon '" .. hlTable.str .. "'"
		)
	end
end

--------------------------
--[[ SUMMARY:
	* Run `mode` to refresh the screen.
	* The function was not named `nvim_mode` because that would be really confusing given the name of this plugin.
]]
--------------------------
function api.nvim_redraw()
	api.nvim_command('mode')
end

--------------------------------------
--[[ SUMMARY:
	* Show a `title` error.
]]
--[[ PARAMS:
	* `title` => the title of the error.
	* `msg` => the message of the error.
]]
--------------------------------------
function api.nvim_show_err(title, msg)
	api.nvim_lecho({
		Entry.new('Title', title .. '\n'),
		Entry.new('Error', msg),
		Entry.new('Question', '\n[Press any key to return]')
	})
	api.nvim_command('call getchar()')
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return api
