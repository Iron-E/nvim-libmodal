--- Normalizes a `buffer = true|false|0` argument into a number.
--- @param buffer boolean|number the argument to normalize
--- @return nil|number
local function normalize_buffer(buffer)
	if buffer == true or buffer == 0 then
		return vim.api.nvim_get_current_buf()
	elseif buffer == false then
		return nil
	end

	return buffer
end

--- remove and return the right-hand side of a `keymap`.
--- @param keymap table the keymap to unpack
--- @return function|string rhs, table options
local function unpack_keymap_rhs(keymap)
	local rhs = keymap.rhs or ''
	keymap.rhs = nil

	return rhs, keymap
end

--- @class libmodal.Layer
--- @field private existing_keymaps_by_mode table the keymaps to restore when exiting the mode; generated automatically
--- @field private layer_keymaps_by_mode table the keymaps to apply when entering the mode; provided by user
local Layer = require('libmodal/src/utils/classes').new(nil)

--- apply the `Layer`'s keymaps buffer.
function Layer:enter()
	if self.existing_keymaps_by_mode then
		vim.notify(
			'nvim-libmodal layer: This layer has already been entered. `:exit()` before entering again.',
			vim.log.levels.ERROR,
			{title = 'nvim-libmodal'}
		)
		return
	end

	-- add local aliases.
	self.existing_keymaps_by_mode = {}

	for mode, new_keymaps in pairs(self.layer_keymaps_by_mode) do
		for lhs, options in pairs(new_keymaps) do
			local rhs, unpacked = unpack_keymap_rhs(options)
			self:map(mode, lhs, rhs, unpacked)
		end
	end
end

--- exit the layer, restoring all previous keymaps.
function Layer:exit()
	if not self.existing_keymaps_by_mode then
		vim.notify('nvim-libmodal layer: you cannot exit a layer without entering it first.', vim.log.levels.ERROR, {title = 'nvim-libmodal'})
		return
	end

	for mode, keymaps in pairs(self.layer_keymaps_by_mode) do
		for lhs, keymap in pairs(keymaps) do
			self:unmap(keymap.buffer, mode, lhs)
		end
	end

	self.existing_keymaps_by_mode = nil
end

--- add a keymap to the mode.
--- @param mode string the mode that this keymap for.
--- @param lhs string the left hand side of the keymap.
--- @param rhs function|string the right hand side of the keymap.
--- @param options table options for the keymap.
--- @see `vim.keymap.set`
function Layer:map(mode, lhs, rhs, options)
	options.buffer = normalize_buffer(options.buffer)
	if self.existing_keymaps_by_mode then -- the layer has been activated
		if not self.existing_keymaps_by_mode[mode] then -- this is the first time that a keymap with this mode is being set
			self.existing_keymaps_by_mode[mode] = {}
		end

		if not self.existing_keymaps_by_mode[mode][lhs] then -- the keymap's state has not been saved.
			for _, existing_keymap in ipairs(
				options.buffer and
				vim.api.nvim_buf_get_keymap(options.buffer, mode) or
				vim.api.nvim_get_keymap(mode)
			) do -- check if this keymap will overwrite something
				if existing_keymap.lhs == lhs then -- mapping this will overwrite something; log the old mapping
					existing_keymap.lhs = nil
					self.existing_keymaps_by_mode[mode][lhs] = existing_keymap
					break
				end
			end
		end

		-- map the `lhs` to `rhs` in `mode` with `options` for the current buffer.
		vim.keymap.set(mode, lhs, rhs, options)
	end

	-- add the new mapping to the layer's keymap
	options.rhs = rhs
	if self.layer_keymaps_by_mode[mode] then
		self.layer_keymaps_by_mode[mode][lhs] = options
	else
		self.layer_keymaps_by_mode[mode] = {[lhs] = options}
	end
end

--- restore one keymapping to its original state.
--- @param buffer nil|number the buffer to unmap from (`nil` if it is not buffer-local)
--- @param mode string the mode of the keymap.
--- @param lhs string the keys which invoke the keymap.
--- @see `vim.api.nvim_del_keymap`
function Layer:unmap(buffer, mode, lhs)
	if self.existing_keymaps_by_mode then
		if self.existing_keymaps_by_mode[mode][lhs] then -- there is an older keymap to go back to, so undo this layer_keymaps_by_mode
			local rhs, options = unpack_keymap_rhs(self.existing_keymaps_by_mode[mode][lhs])
			vim.keymap.set(mode, lhs, rhs, options)
		else
			-- just make the keymap go back to default
			local no_errors, err = pcall(function()
				if buffer then
					vim.api.nvim_buf_del_keymap(buffer, mode, lhs)
				else
					vim.api.nvim_del_keymap(mode, lhs)
				end
			end)

			if not (no_errors or err:match 'E31: No such mapping') then
				vim.notify('nvim-libmodal encountered error while unmapping from layer: ' .. err, vim.log.levels.ERROR, {title = 'nvim-libmodal'})
				return
			end
		end
	end

	-- remove this keymap from the list of ones to restore
	self.existing_keymaps_by_mode[mode][lhs] = nil
end

return
{
	--- @param keymaps_by_mode table the keymaps (e.g. `{n = {gg = {rhs = 'G', silent = true}}}`)
	--- @return libmodal.Layer
	new = function(keymaps_by_mode)
		return setmetatable({layer_keymaps_by_mode = keymaps_by_mode}, Layer)
	end
}
