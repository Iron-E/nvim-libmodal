--- @class libmodal.utils.Help
--- @field private [integer] string[]
local Help = require('libmodal.src.utils.classes').new()

--- align `tbl` according to the `longest_key_len`.
--- @param longest_key_len number how long the longest key is.
--- @param rows {hl: nil|string, columns: {[string]: string|fun()}}[]
--- @return string[][] aligned
local function align_columns(longest_key_len, rows)
	local aligned = {} --- @type string[][]

	for _, row in ipairs(rows) do
		for key, value in pairs(row.columns) do
			table.insert(aligned, {'\n' .. key, row.hl or 'String'})
			table.insert(aligned, {(' '):rep(longest_key_len - vim.api.nvim_strwidth(key)), 'Whitespace'})
			table.insert(aligned, {' │ ', 'Delimiter'})

			local v, hl = value, row.hl
			if type(value) == 'function' then
				v, hl = vim.inspect(v), 'Function'
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
		local value_len = vim.api.nvim_strwidth(value)

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
			{columns = {[('-'):rep(longest_key)] = ('-'):rep(longest_value)}, hl = 'Delimiter'},
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
