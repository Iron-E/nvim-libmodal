--[[
	/*
	 * IMPORTS
	 */
--]]

local globals = require('libmodal/src/base/globals')
local Entry = require('libmodal/src/utils/Indicator/Entry.lua')

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
	local escape = api.nvim_eval("nr2char('" .. 27 .. "')")
	api.nvim_command('normal ' .. escape)
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
--[[
	* `scope` => The scope of the variable (i.e. `g`, `l`, etc.)
	* `var` => the variable to check for.
]]
-----------------------------------
function api.nvim_exists(scope, var)
	return api.nvim_eval("exists('" .. scope .. ":" .. var .. "')") ~= globals.VIM_FALSE
end

-------------------------
--[[ SUMMARY:
	* Gets one character of user input, as a number.
]]
-------------------------
function api.nvim_input()
	return api.nvim_eval('getchar()')
end

------------------------
--[[ SUMMARY:
	* Echo a table of {`hlgroup`, `str`} tables.
	* Meant to be read as "nvim list echo".
]]
--[[ PARAMS:
	* `hlTables` => the tables to echo with highlights.
]]
------------------------
function api.nvim_lecho(hlTables)
	api.nvim_redraw()
	for _, hlTable in ipairs(hlTables) do
		api.nvim_command(
			-- `:echohl` the hlgroup and then `:echon` the string.
			"execute(['echohl " .. hlTable.hl .. "', 'echon " .. hlTable.str .. "'])"
		)
	end
	api.nvim_command('echohl None')
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

-------------------------------
--[[ SUMMARY:
	* Show a `title` error.
]]
--[[ PARAMS:
	* `title` => the title of the error.
	* `msg` => the message of the error.
]]
-------------------------------
function api.nvim_show_err(title, msg)
	api.nvim_lecho({
		Entry.new('Title', title .. '\n'),
		Entry.new('Error', msg),
		Entry.new('Question', '\n[Press any key to return]')
	})
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return api
