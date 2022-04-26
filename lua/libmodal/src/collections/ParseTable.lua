--- the number corresponding to <CR> in vim.
local CR   = 13
local globals = require 'libmodal/src/globals'

--- @class libmodal.collections.ParseTable
local ParseTable = require('libmodal/src/utils/classes').new(nil)

--- reverse the order of elements in some `tbl`
--- @param tbl table the table to reverse
--- @return table tbl_reversed
local function table_reverse(tbl)
	local reversed = {}
	while #reversed < #tbl do
		-- look, no variables!
		reversed[#reversed + 1] = tbl[#tbl - #reversed]
	end
	return reversed
end

--- @param str string
--- @return table<string> chars of `str`
local function chars(str)
	return vim.split(str, '')
end

--- retrieve the mapping of `lhs_reversed_bytes`
--- @param parse_table libmodal.collections.ParseTable the table to fetch `lhs_reversed_bytes` from.
--- @param lhs_reversed_bytes table<string> the characters of the left-hand side of the mapping reversed passed to `string.byte`
--- @return false|function|string|table match a string/func when fully matched; a table when partially matched; false when no match.
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

		if val_type == globals.TYPE_TBL then
			if val[CR] and #lhs_reversed_bytes < 1 then
				return val
			else
				return get(val, lhs_reversed_bytes)
			end
		elseif val_type == globals.TYPE_STR or val_type == globals.TYPE_FUNC and #lhs_reversed_bytes < 1 then
			return val
		end
	end
	return nil
end

--- insert a `value` into `parse_table` at the position indicated by `lhs_reversed_bytes`
--- @param lhs_reversed_bytes table<string> the characters of the left-hand side of the mapping reversed passed to `string.byte`
--- @param value function|string the right-hand-side of the mapping
local function put(parse_table, lhs_reversed_bytes, value)
	--[[ Get the next character in the table. ]]
	local byte = string.byte(table.remove(lhs_reversed_bytes))

	if #lhs_reversed_bytes > 0 then -- there are still characters left in the key.
		if not parse_table[byte] then -- this is a new mapping
			parse_table[byte] = {}
		else -- if there is a previous command mapping in place
			local value_type = type(parse_table[byte])
			if value_type == globals.TYPE_STR or value_type == globals.TYPE_FUNC then -- if this is not a tree of inputs already
				-- make the mapping require hitting enter before executing
				parse_table[byte] = {[CR] = parse_table[byte]}
			end
		end

		-- run put() again
		put(parse_table[byte], lhs_reversed_bytes, value)
	-- if parse_Table[k] is a pre-existing table, don't clobber the table— clobber the `CR` value.
	elseif type(parse_table[byte]) == globals.TYPE_TBL then
		parse_table[byte][CR] = value
	else
		parse_table[byte] = value -- parse_table[k] is not a table, go ahead and clobber the value.
	end
end

--- retrieve the mapping of `lhs_reversed_bytes`
--- @param key_dict table a list of characters (most recent input first)
--- @return false|function|string|table match a string/func when fully matched; a table when partially matched; false when no match.
function ParseTable:get(key_dict)
	return get(self, table_reverse(key_dict))
end

--- parse `key` and retrieve its value
--- @param key string the left-hand-side of the mapping to retrieve
--- @return false|function|string|table match a string/func when fully found; a table when partially found; false when not found.
function ParseTable:parse_get(key)
	local parsed_table = chars(string.reverse(key))

	-- convert all of the strings to bytes.
	for i, v in ipairs(parsed_table) do
		parsed_table[i] = string.byte(v)
	end

	return get(self, parsed_table)
end

--- parse `key` and assign it to `value`.
--- @param key string the left-hand-side of the mapping
--- @param value function|string the right-hand-side of the mapping
function ParseTable:parse_put(key, value)
	put(self, chars(string.reverse(key)), value)
end

--- `:parse_put` all `{key, value}` pairs in `keys_and_values`.
--- @param keys_and_values table<string, function|string>
function ParseTable:parse_put_all(keys_and_values)
	for k, v in pairs(keys_and_values) do
		self:parse_put(k, v)
	end
end

return
{
	CR = CR,

	--- create a new `libmodal.collections.ParseTable` from a user-provided table.
	--- @param user_table table keymaps (e.g. `{zfo = 'tabnew'}`)
	--- @return libmodal.collections.ParseTable
	new = function(user_table)
		local self = setmetatable({}, ParseTable)

		-- parse the passed in table.
		self:parse_put_all(user_table)

		-- return the new `ParseTable`.
		return self
	end,
}
