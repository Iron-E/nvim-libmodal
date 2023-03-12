local utils = require('libmodal.src.utils') --- @type libmodal.utils

--- the number corresponding to `<CR>` in vim.
local CR = utils.api.replace_termcodes('<CR>'):byte()

--- @class libmodal.collections.ParseTable
--- @field CR number the byte representation of `<CR>`
local ParseTable = utils.classes.new {CR = CR}

--- reverse the order of elements in some `list`.
--- @generic T
--- @param list T[]
--- @return T[] reversed
local function table_reverse(list)
	local reversed = {}
	for i = #list, 1, -1 do
		table.insert(reversed, list[i])
	end
	return reversed
end

--- @param s string
--- @return string[] chars of `str`
local function chars(s)
	return vim.split(s, '', {plain = true, trimempty = true})
end

--- retrieve the mapping of `lhs_reversed_bytes`
--- @param parse_table libmodal.collections.ParseTable the table to fetch `lhs_reversed_bytes` from.
--- @param lhs_reversed_bytes string[]|integer[] the characters of the left-hand side of the mapping reversed passed to `string.byte`
--- @return false|fun()|nil|string|table match a string/func when fully matched; a table when partially matched; false when no match.
local function get(parse_table, lhs_reversed_bytes)
	--[[ Get the next character in the keymap string. ]]

	local k = ''
	if #lhs_reversed_bytes > 0 then -- there is more input to parse
		k = table.remove(lhs_reversed_bytes) -- the table should already be `string.byte`'d
	else -- the user input has run out, but there is more in the `parse_table`.
		return parse_table
	end

	--[[ Parse the `k`. ]]

	-- make sure the dicitonary has a key for that value.
	if parse_table[k] then
		local val = parse_table[k]
		local val_type = type(val)

		if val_type == 'table' then
			if val[CR] and #lhs_reversed_bytes < 1 then
				return val
			else
				return get(val, lhs_reversed_bytes)
			end
		elseif val_type == 'string' or val_type == 'function' and #lhs_reversed_bytes < 1 then
			return val
		end
	end

	return nil
end

--- insert a `value` into `parse_table` at the position indicated by `lhs_reversed_bytes`
--- @param lhs_reversed_bytes string[] the characters of the left-hand side of the mapping reversed passed to `string.byte`
--- @param value fun()|string the right-hand-side of the mapping
--- @return nil
local function put(parse_table, lhs_reversed_bytes, value)
	--[[ Get the next character in the table. ]]
	local byte = table.remove(lhs_reversed_bytes):byte()

	if #lhs_reversed_bytes > 0 then -- there are still characters left in the key.
		if not parse_table[byte] then -- this is a new mapping
			parse_table[byte] = {}
		else -- if there is a previous command mapping in place
			local value_type = type(parse_table[byte])
			if value_type == 'string' or value_type == 'function' then -- if this is not a tree of inputs already
				-- make the mapping require hitting enter before executing
				parse_table[byte] = {[CR] = parse_table[byte]}
			end
		end

		-- run put() again
		put(parse_table[byte], lhs_reversed_bytes, value)
	-- if parse_Table[k] is a pre-existing table, don't clobber the table— clobber the `CR` value.
	elseif type(parse_table[byte]) == 'table' then
		parse_table[byte][CR] = value
	else
		parse_table[byte] = value -- parse_table[k] is not a table, go ahead and clobber the value.
	end
end

--- retrieve the mapping of `lhs_reversed_bytes`
--- @param key_dict table a list of characters (most recent input first)
--- @return false|fun()|nil|string|table match a string/func when fully matched; a table when partially matched; false when no match.
function ParseTable:get(key_dict)
	return get(self, table_reverse(key_dict))
end

--- create a new `libmodal.collections.ParseTable` from a user-provided table.
--- @param user_table table keymaps (e.g. `{zfo = 'tabnew'}`)
--- @return libmodal.collections.ParseTable
function ParseTable.new(user_table)
	local self = setmetatable({}, ParseTable)

	-- parse the passed in table.
	self:parse_put_all(user_table)

	-- return the new `ParseTable`.
	return self
end

--- parse `key` and retrieve its value
--- @param key string the left-hand-side of the mapping to retrieve
--- @return false|fun()|nil|string|table match a string/func when fully found; a table when partially found; false when not found.
function ParseTable:parse_get(key)
	--- @type table<number|string>
	local parsed_table = chars(key:reverse())

	-- convert all of the strings to bytes.
	for i, v in ipairs(parsed_table) do
		parsed_table[i] = v:byte()
	end

	return get(self, parsed_table)
end

--- parse `key` and assign it to `value`.
--- @param key string the left-hand-side of the mapping
--- @param value fun()|string the right-hand-side of the mapping
--- @return nil
function ParseTable:parse_put(key, value)
	put(self, chars(key:reverse()), value)
end

--- `:parse_put` all `{key, value}` pairs in `keys_and_values`.
--- @param keys_and_values {[string]: fun()|string}
--- @return nil
function ParseTable:parse_put_all(keys_and_values)
	for k, v in pairs(keys_and_values) do
		self:parse_put(k, v)
	end
end

return ParseTable
