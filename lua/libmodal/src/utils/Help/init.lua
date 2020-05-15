--[[
	/*
	 * CLASS `Help`
	 */
--]]

local Help = {}

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
	local longestKey = 0
	for k, v in pairs(commandsOrMaps) do
		local len = string.len(k)
		if len > longestKey then
			longestKey = len
		end
	end

	-- adjust the longest key length if the table header is longer.
	if longestKey < string.len(title) then
		longestKey = string.len(title)
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

	-- define the separator for the help table.
	local helpSeparator = {}
	while #helpSeparator < string.len(title) do
		helpSeparator[#helpSeparator + 1] = '-'
	end
	helpSeparator = table.concat(helpSeparator)

	-- Create a new `Help`.
	return {
		[1] = ' ',
		[2] = table.concat(tabAlign({
			[title] = 'VIM EXPRESSION',
		})),
		[3] = table.concat(tabAlign({
			[helpSeparator] = '--------------'
		})),
		[4] = table.concat(tabAlign(commandsOrMaps)),
		-----------------------
		--[[ SUMMARY:
			* Show the contents of this `Help`.
		]]
		-----------------------
		show = function(__self)
			for _, v in ipairs(__self) do
				print(v)
			end
			vim.api.nvim_call_function('getchar', {})
		end
	}
end

--[[
	/*
	 * PUBLICIZE `Help`.
	 */
--]]

return Help
