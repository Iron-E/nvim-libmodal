--[[
	/*
	 * IMPORTS
	 */
--]]

local api     = vim.api
local globals = require('libmodal/src/base/globals')
local strings = require('libmodal/src/utils/strings')

--[[
	/*
	 * MODULE
	 */
--]]

local ParseTable = {}

--[[
	/*
	 * CLASS `ParseTable`
	 */
--]]

---------------------------------
--[[ SUMMARY:
	* Reverse the elements of some table.
]]
--[[ PARAMS:
	* `tbl` => the table to reverse.
]]
---------------------------------
local function _tableReverse(tbl)
	local reversed = {}
	local i = #tbl
	while i > 0 do
		table.insert(reversed, tbl[i])
		i = i - 1
	end
	return reversed
end

--[[
	/*
	 * CLASS `ParseTable`
	 */
--]]

-- The number corresponding to <CR> in vim.
ParseTable.CR = 13

----------------------------------
--[[ SUMMARY:
	* Create a new parse table from a user-defined table.
]]
--[[ PARAMS:
	* `userTable` => the table of combos defined by the user.
]]
----------------------------------
function ParseTable.new(userTable)
	local parseTable = {}

	--------------------------------
	--[[ SUMMARY:
		* Get a value from this `ParseTable`.
	]]
	--[[ PARAMS:
		* `key` => the PARSED key to get.
	]]
	--[[
		* `function` => when `key` is a full match.
		* `table`    => when the `key` partially mathes.
		* `false`    => when `key` is not ANYWHERE.
	]]
	--------------------------------
	function parseTable:get(keyDict)
		local function parseGet(dict, splitKey)
			--[[ Get the next character in the combo string. ]]

			local k = ''
			if #splitKey > 0 then -- There is more input to parse
				k = table.remove(splitKey) -- the dict should already be `char2nr()`'d
			else -- The user input has run out, but there is more in the dictionary.
				return dict
			end

			--[[ Parse the `k`. ]]

			-- Make sure the dicitonary has a key for that value.
			if dict[k] then
				val = dict[k]
				local valType = type(val)

				if valType == globals.TYPE_TBL then
					if val[ParseTable.CR] and #splitKey < 1 then
						return val
					else
						return parseGet(val, splitKey)
					end
				elseif valType == globals.TYPE_STR and #splitKey < 1 then
					return val
				end
			end
			return false
		end

		--[[ Reverse the dict. ]]
		local reversed = _tableReverse(keyDict)

		--[[ Get return value. ]]
		-- run the inner recursive function in order to return the desired result
		return parseGet(self, reversed)
	end

	----------------------------------------
	--[[ SUMMARY:
		* Put `value` into the parse tree as `key`.
	]]
	--[[ PARAMS:
		* `key` => the key that `value` is reffered to by.
		* `value` => the value to store as `key`.
	]]
	----------------------------------------
	function parseTable:parsePut(key, value)
		-- Internal recursion function.
		local function update(dict, splitKey) -- †
			-- Get the next character in the table.
			local k = string.byte(table.remove(splitKey))

			-- If there are still kacters left in the key.
			if #splitKey > 0 then
				if not dict[k] then
					dict[k] = {}
				-- If there is a previous command mapping in place
				elseif type(dict[k]) == globals.TYPE_STR then
					-- Swap the mapping to a `CR`
					dict[k] = {[ParseTable.CR] = dict[k]}
				end

				-- run update() again
				update(dict[k], splitKey)
			-- If dict[k] is a pre-existing table, don't clobber the table— clobber the `CR` value.
			elseif type(dict[k]) == globals.TYPE_TBL then
				dict[k][ParseTable.CR] = value
			-- If dict[k] is not a table, go ahead and clobber the value.
			else
				dict[k] = value
			end
		end -- ‡

		-- Run the recursive function.
		update(self, strings.split(
			string.reverse(key), '.'
		))
	end

	---------------------------------------------
	--[[ SUMMARY:
		* Create the union of `self` and `tableToUnite`
	]]
	--[[ PARAMS:
		* `tableToUnite` => the table to unite with `self.`
	]]
	---------------------------------------------
	function parseTable:parsePutAll(tableToUnite)
		for k, v in pairs(tableToUnite) do
			self:parsePut(k, v)
		end
	end

	-- Parse the passed in table.
	parseTable:parsePutAll(userTable)
	-- Return the new `ParseTable`.
	return parseTable
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return ParseTable
