--[[
	/*
	 * MODULE
	 */
--]]

local DateTime = {}

--[[
	/*
	 * CLASS `DateTime`
	 */
--]]

-----------------------
--[[ SUMMARY:
	* Get the current date.
]]
-----------------------
function DateTime.now()
	dateTime = os.date("*t")

	-------------------------------
	--[[ SUMMARY:
		* Add some `duration` to `self`.
	]]
	--[[ PARAMS:
		* `duration` => the duration of time to add.
	]]
	--[[ RETURNS:
		* A new `DateTime` with the added seconds.
	]]
	-------------------------------
	function dateTime:add(seconds)
		local time
		-- Copy `self` to `time`
		for k,v in pairs(self) do
			time[k] = v
		end
		-- Add `seconds` to `time`
		time.sec = time.sec + seconds
		return time
	end

	return dateTime
end

--[[
	/*
	 * PUBLICIZE MODULE
	 */
--]]

return DateTime
