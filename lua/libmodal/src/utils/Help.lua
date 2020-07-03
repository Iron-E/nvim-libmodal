--[[
	/*
	 * MODULE
	 */
--]]

local Help = {['TYPE'] = 'libmodal-help'}

--[[
	/*
	 * META `Help`
	 */
--]]

local _metaHelp = require('libmodal/src/classes').new(Help.TYPE)

-------------------------
--[[ SUMMARY:
	* Show the contents of this `Help`.
]]
-------------------------
function _metaHelp:show()
	for _, helpText in ipairs(self) do
		print(helpText)
	end
	vim.api.nvim_call_function('getchar', {})
end

--[[
	/*
	 * CLASS `Help`
	 */
--]]


----------------------------------------
--[[ SUMMARY:
	* Create a default help table with `commandsOrMaps` and vim expressions.
]]
--[[ PARAMS:
	* `commandsOrMaps` => the table of commands or mappings to vim expressions.
]]
--[[ RETURNS:
	* A new `Help`.
]]
----------------------------------------
function Help.new(commandsOrMaps, title)
	-- find the longest key in the table.
	local longestKeyLen = 0
	for key, _ in pairs(commandsOrMaps) do
		local keyLen = string.len(key)
		if keyLen > longestKeyLen then
			longestKeyLen = keyLen
		end
	end

	-- adjust the longest key length if the table header is longer.
	if longestKeyLen < string.len(title) then
		longestKeyLen = string.len(title)
	end

	-- define the separator for entries in the help table.
	local SEPARATOR_TEMPLATE = {' │ ', '\n'}

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
	local function tabAlign(tbl)
		local toPrint = {}
		for k, v in pairs(tbl) do
			toPrint[#toPrint + 1] = k
			local len = string.len(k)
			local byte = string.byte(k)
			-- account for ASCII chars that take up more space.
			if byte <= 32 or byte == 127 then len = len + 1
			end

			for _ = len, longestKeyLen do
				toPrint[#toPrint + 1] = ' '
			end
			toPrint[#toPrint + 1] = table.concat(SEPARATOR_TEMPLATE, v)
		end
		return toPrint
	end

	-- define the separator for the help table.
	local helpSeparator = {}
	for i = 1, string.len(title) do
		helpSeparator[i] = '-'
	end
	helpSeparator = table.concat(helpSeparator)

	-- Create a new `Help`.
	return setmetatable(
		{
			[1] = ' ',
			[2] = table.concat(tabAlign({
				[title] = 'VIM EXPRESSION'
			})),
			[3] = table.concat(tabAlign({
				[helpSeparator] = '--------------'
			})),
			[4] = table.concat(tabAlign(commandsOrMaps)),
		},
		_metaHelp
	)
end

--[[
	/*
	 * PUBLICIZE `Help`.
	 */
--]]

return Help
