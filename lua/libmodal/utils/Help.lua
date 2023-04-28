--- The horizontal separator of the help output
local HORIZONTAL_DELIMITER = '─'

--- @class libmodal.utils.Help
--- @field private [integer] string[]
local Help = require('libmodal.utils.classes').new()

--- align `tbl` according to the `longest_key_len`.
--- @param longest_key_len number how long the longest key is.
--- @param rows {hl: nil|string, columns: {[string]: string|fun()}}[]
--- @return string[][] aligned
local function align_columns(longest_key_len, rows)
	local aligned = {} --- @type string[][]

	for _, row in ipairs(rows) do
		local sorted_columns = vim.tbl_keys(row.columns)
		table.sort(sorted_columns)

		for _, key in pairs(sorted_columns) do
			local value = row.columns[key]

			table.insert(aligned, {'\n' .. key, row.hl or 'String'})
			table.insert(aligned, {(' '):rep(longest_key_len - vim.api.nvim_strwidth(key)), 'Whitespace'})

			if row.hl == 'Delimiter' then
				table.insert(aligned, {HORIZONTAL_DELIMITER .. '┼' .. HORIZONTAL_DELIMITER, 'Delimiter'})
			else
				table.insert(aligned, {' │ ', 'Delimiter'})
			end

			local hl = row.hl
			if type(value) == 'function' then
				value, hl = tostring(value), 'Function'
			end

			table.insert(aligned, {value, hl or 'String'})
		end
	end

	return aligned
end

--- create a default help table with `commands_or_maps` and vim expressions.
--- @param commands_or_maps {[string]: fun()|string} commands or mappings to vim expressions.
--- @param title string
--- @return libmodal.utils.Help
function Help.new(commands_or_maps, title)
	local COLUMN_NAME = 'VIM EXPRESSION'

	--- the longest key in the table
	local longest_key, longest_value = vim.api.nvim_strwidth(title), COLUMN_NAME:len()
	for key, value in pairs(commands_or_maps) do
		local key_len = vim.api.nvim_strwidth(key)
		local value_len = vim.api.nvim_strwidth(tostring(value))

		if key_len > longest_key then
			longest_key = key_len
		end

		if value_len > longest_value then
			longest_value = value_len
		end
	end

	return setmetatable(
		align_columns(longest_key, {
			{columns = {[title] = COLUMN_NAME}, hl = 'Title'},
			{
				columns = {[(HORIZONTAL_DELIMITER):rep(longest_key)] = (HORIZONTAL_DELIMITER):rep(longest_value)},
				hl = 'Delimiter',
			},
			{columns = commands_or_maps},
		}),
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
