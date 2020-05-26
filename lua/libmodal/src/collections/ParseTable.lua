--[[
	/*
	 * IMPORTS
	 */
--]]

local globals    = require('libmodal/src/globals')

--[[
	/*
	 * MODULE
	 */
--]]

local _REGEX_ALL = '.'

local ParseTable = {
	['CR']    = 13, -- The number corresponding to <CR> in vim.
	['TYPE']  = 'libmodal-parse-table'
}

-------------------------------------------
--[[ SUMMARY:
	* Split some `str` over a `regex`.
]]
--[[ PARAMS:
	* `str` => the string to split.
	* `regex` => the regex to split `str` with.
]]
--[[ RETURNS:
	* The split `str`.
]]
-------------------------------------------
function ParseTable.stringSplit(str, regex)
	local split = {}
	for char in string.gmatch(str, regex) do
		split[#split + 1] = char
	end
	return split
end

-------------------------------------
--[[ SUMMARY:
	* Reverse the elements of some table.
]]
--[[ PARAMS:
	* `tbl` => the table to reverse.
]]
--[[ RETURNS:
	* The reversed `tbl`.
]]
-------------------------------------
function ParseTable.tableReverse(tbl)
	local reversed = {}
	while #reversed < #tbl do
		-- look, no variables!
		reversed[#reversed + 1] = tbl[#tbl - #reversed]
	end
	return reversed
end

------------------------------
--[[ SUMMARY:
	* Parse a `key`.
]]
--[[ PARAMS:
	* `key` => the key to parse.
]]
--[[ RETURNS:
	* The parsed `key`.
]]
------------------------------
function ParseTable.parse(key)
	return ParseTable.stringSplit(string.reverse(key), _REGEX_ALL)
end

-----------------------------------------
--[[ SUMMARY
	* Get `splitKey` from some `parseTable`.
]]
--[[ PARAMS:
	* `parseTable` => the table to fetch `splitKey` from.
	* `splitKey` => the key split into groups.
]]
-----------------------------------------
local function _get(parseTable, splitKey)
	--[[ Get the next character in the combo string. ]]

	local k = ''
	if #splitKey > 0 then -- There is more input to parse
		k = table.remove(splitKey) -- the table should already be `char2nr()`'d
	else -- the user input has run out, but there is more in the `parseTable`.
		return parseTable
	end

	--[[ Parse the `k`. ]]

	-- Make sure the dicitonary has a key for that value.
	if parseTable[k] then
		local val = parseTable[k]
		local valType = type(val)

		if valType == globals.TYPE_TBL then
			if val[ParseTable.CR] and #splitKey < 1 then
				return val
			else
				return _get(val, splitKey)
			end
		elseif valType == globals.TYPE_STR and #splitKey < 1 then
			return val
		end
	end
	return nil
end

-----------------------------------------
--[[ SUMMARY:
	* Update the values of some `dict` using a `splitKey`.
]]
--[[ PARAMS:
	* `parseTable` => the parseTable to update.
	* `splitKey` => the key split into groups.
]]
-----------------------------------------
local function _put(parseTable, splitKey, value) -- †
	--[[ Get the next character in the table. ]]
	local k = string.byte(table.remove(splitKey))

	if #splitKey > 0 then -- there are still characters left in the key.
		if not parseTable[k] then parseTable[k] = {}
		-- If there is a previous command mapping in place
		elseif type(parseTable[k]) == globals.TYPE_STR then
			-- Swap the mapping to a `CR`
			parseTable[k] = {[ParseTable.CR] = parseTable[k]}
		end

		-- run _update() again
		_put(parseTable[k], splitKey, value)
	-- If parseTable[k] is a pre-existing table, don't clobber the table— clobber the `CR` value.
	elseif type(parseTable[k]) == globals.TYPE_TBL then
		parseTable[k][ParseTable.CR] = value
	else parseTable[k] = value -- parseTable[k] is not a table, go ahead and clobber the value.
	end
end -- ‡

--[[
	/*
	 * META `ParseTable`
	 */
--]]

local _metaParseTable = require('libmodal/src/classes').new(ParseTable.TYPE)

------------------------------------------
--[[ SUMMARY:
	* Get a value from this `ParseTable`.
]]
--[[ PARAMS:
	* `key` => the PARSED key to get.
]]
--[[ RETURNS:
	* `function` => when `key` is a full match.
	* `table`    => when the `key` partially mathes.
	* `false`    => when `key` is not ANYWHERE.
]]
------------------------------------------
function _metaParseTable:get(keyDict)
	return _get(self, keyDict)
end

--------------------------------------
--[[ SUMMARY:
	* Get a value from this `ParseTable`.
]]
--[[ PARAMS:
	* `key` => the key to get.
]]
--[[ RETURNS:
	* `function` => when `key` is a full match.
	* `table`    => when the `key` partially mathes.
	* `false`    => when `key` is not ANYWHERE.
]]
--------------------------------------
function _metaParseTable:parseGet(key)
	local parsedTable = ParseTable.parse(key)

	-- convert all of the strings to bytes.
	for i, v in ipairs(parsedTable) do
		parsedTable[i] = string.byte(v)
	end

	return _get(self, parsedTable)
end

---------------------------------------------
--[[ SUMMARY:
	* Put `value` into the parse tree as `key`.
]]
--[[ PARAMS:
	* `key` => the key that `value` is reffered to by.
	* `value` => the value to store as `key`.
]]
---------------------------------------------
function _metaParseTable:parsePut(key, value)
	_put(self, ParseTable.parse(key), value)
end

--------------------------------------------------
--[[ SUMMARY:
	* Create the union of `self` and `tableToUnite`
]]
--[[ PARAMS:
	* `tableToUnite` => the table to unite with `self.`
]]
--------------------------------------------------
function _metaParseTable:parsePutAll(tableToUnite)
	for k, v in pairs(tableToUnite) do
		self:parsePut(k, v)
	end
end

--[[
	/*
	 * CLASS `ParseTable`
	 */
--]]

----------------------------------
--[[ SUMMARY:
	* Create a new parse table from a user-defined table.
]]
--[[ PARAMS:
	* `userTable` => the table of combos defined by the user.
]]
----------------------------------
function ParseTable.new(userTable)
	local self = setmetatable({}, _metaParseTable)

	-- Parse the passed in table.
	self:parsePutAll(userTable)

	-- Return the new `ParseTable`.
	return self
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return ParseTable
