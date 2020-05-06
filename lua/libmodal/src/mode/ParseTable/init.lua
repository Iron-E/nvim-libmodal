--[[
	/*
	 * IMPORTS
	 */
--]]

local api     = vim.api
local globals = require('libmodal/src/base/globals')

--[[
	/*
	 * MODULE
	 */
--]]

local ParseTable = {}
local strings    = {} -- not to be returned. Used for split() function.

--[[
	/*
	 * CONSTANTS
	 */
--]]

-- The number corresponding to <CR> in vim.
ParseTable.CR = 13

--[[
	/*
	 * f(x)
	 */
--]]
function strings.split(str, pattern)
	local split = {}
	for char in string.gmatch(str, pattern) do
		table.insert(split, char)
	end
	return split
end

-------------------------
--[[ SUMMARY:
	* Create a new parse table from a user-defined table.
]]
--[[ PARAMS:
	* `userTable` => the table of combos defined by the user.
]]
-------------------------
function ParseTable:new(userTable)
	local parseTable = {}

	-------------------------------
	--[[ SUMMARY:
		* Put `value` into the parse tree as `key`.
	]]
	--[[ PARAMS:
		* `key` => the key that `value` is reffered to by.
		* `value` => the value to store as `key`.
	]]
	-------------------------------
	function parseTable:parsePut(key, value)
		-- Internal recursion function.
		local function update(dict, splitKey) -- †
			-- Get the next character in the table.
			local k = api.nvim_eval("char2nr('" .. table.remove(splitKey) .. "')")

			-- If there are still kacters left in the key.
			if #splitKey > 0 then
				if not dict[k] then
					dict[k] = {}
				-- If there is a previous command mapping in place
				elseif type(dict[k]) == 'string' then
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

	-------------------------------
	--[[ SUMMARY:
		* Create the union of `self` and `tableToUnite`
	]]
	--[[ PARAMS:
		* `tableToUnite` => the table to unite with `self.`
	]]
	-------------------------------
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
