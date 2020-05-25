--[[
	/*
	 * IMPORTS
	 */
--]]

local api     = vim.api
local classes = require('libmodal/src/classes')

--[[
	/*
	 * MODULE
	 */
--]]

local Layer = {['TYPE'] = 'libmodal-layer'}

local _BUFFER_CURRENT = 0
local _RESTORED       = nil

local function convertKeymap(keymapEntry)
	local lhs = keymapEntry.lhs
	            keymapEntry.lhs = nil

	return {lhs, keymapEntry}
end

local function deconvertKeymap(convertedKeymap)
	local rhs = convertedKeymap.rhs
	            convertedKeymap.rhs = nil

	return {rhs, convertedKeymap}
end

--[[
	/*
	 * META `Layer`
	 */
--]]

local _metaLayer = classes.new(Layer.TYPE)

---------------------------
--[[ SUMMARY:
	* Enter the `Layer`.
	* Only activates for the current buffer.
]]
---------------------------
function _metaLayer:enter()
	-- add local aliases.
	local layerKeymap = self._keymap
	local priorKeymap = {}

	--[[ iterate over the new mappings to both:
	     1. Populate `priorKeymap`
		 2. Map the `layerKeymap` to the buffer. ]]
	for mode, newMappings in pairs(layerKeymap) do
		-- if `mode` key has not yet been made for `priorKeymap`.
		if not priorKeymap[mode] then
			priorKeymap[mode] = {}
		end

		-- store the previously mapped keys
		for _, bufMap in ipairs(api.nvim_buf_get_keymap(_BUFFER_CURRENT, mode)) do
			-- if the new mappings would overwrite this one
			if newMappings[bufMap.lhs] then
				-- remove values so that it is in line with `nvim_set_keymap`.
				local lhs, keymap = unpack(convertKeymap(bufMap))
				priorKeymap[mode][lhs] = keymap
			end
		end

		-- add the new mappings
		for lhs, newMapping in pairs(newMappings) do
			local rhs, options = unpack(deconvertKeymap(newMapping))
			api.nvim_buf_set_keymap(_BUFFER_CURRENT, mode, lhs, rhs, options)
		end
	end

	print(vim.inspect(priorKeymap))
	self._priorKeymap = priorKeymap
end

--------------------------------------------------------
--[[ SUMMARY:
	* Add a mapping to the mode.
]]
--[[ PARAMS:
	* `mode`    => the mode that this mapping for.
	* `lhs`     => the left hand side of the mapping.
	* `rhs`     => the right hand side of the mapping.
	* `options` => options for the mapping.
]]
--[[ SEE ALSO:
	* `nvim_buf_set_keymap()`
]]
--------------------------------------------------------
function _metaLayer:_mapToBuffer(mode, lhs, rhs, options)
	local priorKeymap = self._priorKeymap

	if not priorKeymap then error(
		"You can't map to a buffer without activating the layer first."
	) end

	if not priorKeymap[mode][lhs] then -- the mapping's state has not been saved.
		for _, bufMap in
			ipairs(api.nvim_buf_get_keymap(_BUFFER_CURRENT, mode))
		do -- check if it exists in the buffer
			if bufMap.lhs == lhs then -- add it to the undo list
				priorKeymap[mode][lhs] = unpack(convertKeymap(bufMap))
				break
			end
		end
	end

	-- map the `lhs` to `rhs` in `mode` with `options` for the current buffer.
	api.nvim_buf_set_keymap(_BUFFER_CURRENT, mode, lhs, rhs, options)
end

------------------------------------------------
--[[ SUMMARY:
	* Add a mapping to the mode.
]]
--[[ PARAMS:
	* `mode`    => the mode that this mapping for.
	* `lhs`     => the left hand side of the mapping.
	* `rhs`     => the right hand side of the mapping.
	* `options` => options for the mapping.
]]
--[[ SEE ALSO:
	* `nvim_buf_set_keymap()`
]]
------------------------------------------------
function _metaLayer:map(mode, lhs, rhs, options)
	if self._priorKeymap then -- the layer has been activated.
		self:_mapToBuffer(mode, lhs, rhs, options)
	end

	-- add the new mapping to the keymap
	self._keymap[mode][lhs] = vim.tbl_extend('force',
		options, {['rhs'] = rhs}
	)
	print(vim.inspect(self._priorKeymap))
end

----------------------------------------------
--[[ SUMMARY:
	* Undo a mapping after `enter()`.
]]
--[[ PARAMS:
	* `mode` => the mode to map (e.g. `n`, `i`).
	* `lhs` => the mapping to undo.
]]
----------------------------------------------
function _metaLayer:_unmapFromBuffer(mode, lhs)
	local priorKeymap  = self._priorKeymap
	local priorMapping = self._priorKeymap[mode][lhs]

	print('unmapping ' .. mode .. ':' .. lhs)

	if not priorKeymap then error(
		"You can't undo a map from a buffer without activating the layer first."
	) end

	if priorMapping then -- there is an older mapping to go back to.
		-- undo the mapping
		local rhs, deconvertedKeymap = unpack(deconvertKeymap(priorMapping))
		api.nvim_buf_set_keymap(_BUFFER_CURRENT, mode, lhs, rhs, deconvertedKeymap)

		-- set the prior mapping as restored.
		priorKeymap[mode][lhs] = _RESTORED

		print('reverted mapping')
	else
		-- just delete the buffer mapping.
		local noErrors, err = pcall(api.nvim_buf_del_keymap, _BUFFER_CURRENT, mode, lhs)

		if not noErrors then print(err) end
		print('deleted mapping')
	end
end

------------------------------------
--[[ SUMMARY:
	* Remove a mapping from the mode.
]]
--[[ PARAMS:
	* `mode` => the mode that this mapping for.
	* `lhs`  => the left hand side of the mapping.
]]
--[[ SEE ALSO:
	* `nvim_buf_del_keymap()`
]]
------------------------------------
function _metaLayer:unmap(mode, lhs)
	-- unmap for the buffer too, if the layer is activated.
	if self._priorKeymap then
		self:_unmapFromBuffer(mode, lhs)
	end

	-- remove the mapping from the internal keymap
	self._keymap[mode][lhs] = _RESTORED
end

--------------------------
--[[ SUMMARY:
	* Exit the layer.
]]
--------------------------
function _metaLayer:exit()
	for mode, mappings in pairs(self._keymap) do
		for lhs, _ in pairs(mappings) do
			self:_unmapFromBuffer(mode, lhs)
		end
	end
	self._priorKeymap = _RESTORED
end

--[[
	/*
	 * CLASS `Layer`
	 */
--]]

-----------------------------------------------------
--[[ SUMMARY:
	* Create a new `Layer` for `commands`, `mappings`, and `options`.
]]
--[[ PARAMS:
	* `name` => the name of the layer.
	* `mappings` => the list of user mappings to replace.
]]
--[[ RETURNS:
	* A new `Layer`.
]]
-----------------------------------------------------
function Layer.new(name, mappings)
	return setmetatable(
		{['_keymap'] = mappings, ['name'] = name},
		_metaLayer
	)
end

--[[
	/*
	 * PUBLICIZE `Layer`
	 */
--]]

return Layer
