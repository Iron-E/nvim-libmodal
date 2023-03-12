--- @class libmodal.utils.Help
local Help = require('libmodal.src.utils.classes').new()

--- align `tbl` according to the `longest_key_len`.
--- @param tbl {[string]: string|fun()} what to align.
--- @param longest_key_len number how long the longest key is.
--- @return string aligned
local function align_columns(tbl, longest_key_len)
	local to_print = {}

	for key, value in pairs(tbl) do
		table.insert(to_print, key)
		local len = key:len()
		local byte = key:byte()

		-- account for ASCII chars that take up more space.
		if byte <= 32 or byte == 127 then
			len = len + 1
		end

		for _ = len, longest_key_len do
			table.insert(to_print, ' ')
		end

		table.insert(to_print, ' │ ' .. (type(value) == 'string' and value or vim.inspect(value)) .. '\n')
	end

	return table.concat(to_print)
end

--- create a default help table with `commands_or_maps` and vim expressions.
--- @param commands_or_maps {[string]: fun()|string} commands or mappings to vim expressions.
--- @param title string
--- @return libmodal.utils.Help
function Help.new(commands_or_maps, title)
	--- the longest key in the table
	local longest_key = title:len()

	for key, _ in pairs(commands_or_maps) do
		local key_len = key:len()
		if key_len > longest_key then
			longest_key = key_len
		end
	end

	-- create a new `Help`.
	return setmetatable(
		{
			[1] = ' ',
			[2] = align_columns({[title] = 'VIM EXPRESSION'}, longest_key),
			[3] = align_columns({[('-'):rep(title:len())] = '--------------'}, longest_key),
			[4] = align_columns(commands_or_maps, longest_key),
		},
		Help
	)
end

--- show the contents of this `Help`.
--- @return nil
function Help:show()
	vim.api.nvim_echo(self, false, {})
	vim.fn.getchar()
end

return Help
