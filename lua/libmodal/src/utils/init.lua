--[[
	/*
	 * IMPORTS
	 */
--]]

local api = vim.api
local globals = require('libmodal/src/base/globals')

--[[
	/*
	 * MODULE
	 */
--]]

local utils       = {}
utils.api         = require('libmodal/src/utils/api')
utils.DateTime    = require('libmodal/src/utils/DateTime')
utils.Indicator   = require('libmodal/src/utils/Indicator')
utils.vars        = require('libmodal/src/utils/vars')
utils.WindowState = require('libmodal/src/utils/WindowState')

--[[
	/*
	 * FUNCTIONS
	 */
--]]

------------------------------------
--[[ SUMMARY:
	* Show a default help table with `commands` and vim expressions.
]]
--[[ PARAMS:
	* `commands` => the table of commands to vim expressions.
]]
------------------------------------
function utils.commandHelp(commands)
	-- find the longest key in the table.
	local longestKey = 0
	for k, v in pairs(commands) do
		local len = string.len(k)
		if len > longestKey then
			longestKey = len
		end
	end

	-- define the table header on the left side.
	local LEFT_TBL_HEADER = 'COMMAND'

	-- adjust the longest key length if the table header is longer.
	if longestKey < string.len(LEFT_TBL_HEADER) then
		longestKey = string.len(LEFT_TBL_HEADER)
	end

	-- define the separator for entries in the help table.
	local SEPARATOR = ' │ '

	----------------------
	--[[ SUMMARY:
		* Align `tbl` according to the `longestKey`.
	]]
	--[[ PARAMS:
		* `tbl` => the table to align.
	]]
	--[[ RETURNS:
		* The aligned `tbl`.
	]]
	----------------------
	function tabAlign(tbl)
		local toPrint = {}
		for k, v in pairs(tbl) do
			toPrint[#toPrint + 1] = k
			local i = longestKey - string.len(k)
			while i > 0 do
				toPrint[#toPrint + 1] = ' '
				i = i - 1
			end
			toPrint[#toPrint + 1] = SEPARATOR .. v .. '\n'
		end
		return toPrint
	end

	-- print the table headers.
	print(' '); print(table.concat(tabAlign({
		[LEFT_TBL_HEADER] = 'VIM EXPRESSION',
		['-------'] = '--------------'
	})))
	-- print the help table.
	print(table.concat(tabAlign(commands)))
	-- pause redrawing of the prompt.
	api.nvim_call_function('getchar', {})
end

function utils.showError(pcallErr)
	utils.api.nvim_bell()
	utils.api.nvim_show_err(
		globals.DEFAULT_ERROR_MESSAGE,
		api.nvim_get_vvar('throwpoint')
		.. '\n' ..
		api.nvim_get_vvar('exception')
		.. '\n' ..
		tostring(pcallErr)
	)
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return utils
