--[[
	/*
	 * IMPORTS
	 */
--]]

local api = vim.api

--[[
	/*
	 * MODULE
	 */
--]]

local ParseTable = {}
local strings    = {} -- not to be returned.

--[[
	/*
	 * CONSTANTS
	 */
--]]

ParseTable.EXE = 'exe'

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
	return table.concat(split, '')
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
	local userTable = {
		-------------------------------
		--[[ SUMMARY:
			* Put `value` into the parse tree as `key`.
		]]
		--[[ PARAMS:
			* `key` => the key that `value` is reffered to by.
			* `value` => the value to store as `key`.
		]]
		-------------------------------
		_put = function(__self, key, value)
			-- Iterate to get the next dictionaries.
			local function _access(dict, splitKey)
				-- Get the next character in the table.
				local char = api.nvim_eval('char2nr(' .. table.remove(splitKey) .. ')')

				-- If there are still items in the table.
				if #splitKey > 0 then
					if not dict[char] then
						dict[char] = {}
					-- If there is a previous command mapping in place
					elseif type(dict[char]) == 'string' then
						-- Swap the mapping to an s:EX_KEY.
						dict[char] = {[ParseTable.EXE] = dict[char]}
					end

					dict[char] = _access(dict, key)
				elseif dict[key] then
					dict[key][char] = value
				else
					dict[key] = value
				end

				return dict
			end

			-- Iterate over ther eturn from access.
			for k, v in pairs(_access(
				__self, strings.split(string.reverse(key), '.')
			)) do
				table.insert(parsedDict, k, v)
			end
		end,

		-------------------------------
		--[[ SUMMARY:
			* Create the union of `self` and `tableToUnite`
		]]
		--[[ PARAMS:
			* `tableToUnite` => the table to unite with `self.`
		]]
		-------------------------------
		union = function(__self, tableToUnite)
			for k, v in pairs(tableToUnite) do
				if not __self[k] then
					__self:_put(k, v)
				end
			end
		end
	}


	return userTable:_union(userTable)
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]
return ParseTable
