--[[/* IMPORTS */]]

local globals = require('libmodal/src/globals')

--[[/* Utilities */]]

--- Align `tbl` according to the `longestKeyLen`.
--- @param tbl table what to align.
--- @param longestKeyLen number how long the longest key is.
--- @return table aligned
local function tabAlign(tbl, longestKeyLen)
	local toPrint = {}
	for key, value in pairs(tbl) do
		toPrint[#toPrint + 1] = key
		local len = string.len(key)
		local byte = string.byte(key)
		-- account for ASCII chars that take up more space.
		if byte <= 32 or byte == 127 then len = len + 1 end

		for _ = len, longestKeyLen do
			toPrint[#toPrint + 1] = ' '
		end

		toPrint[#toPrint + 1] = table.concat(
			{' │ ', '\n'},
			(type(value) == globals.TYPE_STR) and value or '<lua function>'
		)
	end
	return toPrint
end

--[[/* MODULE */]]

local Help = {TYPE = 'libmodal-help'}

--[[/* META `Help` */]]

local _metaHelp = require('libmodal/src/classes').new(Help.TYPE)

--- Show the contents of this `Help`.
function _metaHelp:show()
	for _, helpText in ipairs(self) do
		print(helpText)
	end
	vim.fn.getchar()
end

--[[/* CLASS `Help` */]]

--- Create a default help table with `commandsOrMaps` and vim expressions.
--- @param commandsOrMaps table commands or mappings to vim expressions.
--- @return table Help
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

	-- define the separator for the help table.
	local helpSeparator = {}
	for i = 1, string.len(title) do helpSeparator[i] = '-' end
	helpSeparator = table.concat(helpSeparator)

	-- Create a new `Help`.
	return setmetatable(
		{
			[1] = ' ',
			[2] = table.concat(tabAlign({[title] = 'VIM EXPRESSION'}, longestKeyLen)),
			[3] = table.concat(tabAlign({[helpSeparator] = '--------------'}, longestKeyLen)),
			[4] = table.concat(tabAlign(commandsOrMaps, longestKeyLen)),
		},
		_metaHelp
	)
end

return Help
