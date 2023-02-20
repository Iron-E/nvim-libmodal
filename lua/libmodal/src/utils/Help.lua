--- @type libmodal.globals
local globals = require 'libmodal/src/globals'

--- @class libmodal.utils.Help
local Help = require('libmodal/src/utils/classes').new(nil)

--- align `tbl` according to the `longest_key_len`.
--- @param tbl table what to align.
--- @param longest_key_len number how long the longest key is.
--- @return table aligned
local function align_columns(tbl, longest_key_len)
	local to_print = {}
	for key, value in pairs(tbl) do
		to_print[#to_print + 1] = key
		local len = string.len(key)
		local byte = string.byte(key)
		-- account for ASCII chars that take up more space.
		if byte <= 32 or byte == 127 then
			len = len + 1
		end

		for _ = len, longest_key_len do
			to_print[#to_print + 1] = ' '
		end

		to_print[#to_print + 1] = ' │ ' .. (type(value) == globals.TYPE_STR and value or vim.inspect(value)) .. '\n'
	end
	return to_print
end

--- create a default help table with `commands_or_maps` and vim expressions.
--- @param commands_or_maps {[string]: fun()|string} commands or mappings to vim expressions.
--- @param title string
--- @return libmodal.utils.Help
function Help.new(commands_or_maps, title)
	-- find the longest key in the table, or at least the length of the title
	local longest_key_maps = string.len(title)
	for key, _ in pairs(commands_or_maps) do
		local key_len = string.len(key)
		if key_len > longest_key_maps then
			longest_key_maps = key_len
		end
	end

	-- create a new `Help`.
	return setmetatable(
		{
			[1] = ' ',
			[2] = table.concat(align_columns({[title] = 'VIM EXPRESSION'}, longest_key_maps)),
			[3] = table.concat(align_columns({[string.rep('-', string.len(title))] = '--------------'}, longest_key_maps)),
			[4] = table.concat(align_columns(commands_or_maps, longest_key_maps)),
		},
		Help
	)
end

--- show the contents of this `Help`.
function Help:show()
	for _, help_text in ipairs(self) do
		print(help_text)
	end
	vim.fn.getchar()
end

return Help
