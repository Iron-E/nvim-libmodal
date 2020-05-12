local strings = {}

------------------------------------
--[[ SUMMARY:
	* Split some `str` using a regex `pattern`.
]]
--[[ PARAMS:
	* `str` => the string to split.
	* `pattern` => the regex pattern to split `str` with.
]]
------------------------------------
function strings.split(str, pattern)
	local split = {}
	local i = 1
	for char in string.gmatch(str, pattern) do
		split[i] = char
		i = i + 1
	end
	return split
end

return strings
