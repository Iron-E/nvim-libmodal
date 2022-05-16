local function termcodes(keys)
	return vim.api.nvim_replace_termcodes(keys, true, true, true)
end

local function extract_key_from_tbl(key, tbl)
	local value
	value, tbl[key] = tbl[key], nil
	return value
end

---@class libmodal.Layer
---@field private active boolean If mode is active or not.
---@field private layer_keymaps table The keymaps to apply when entering the mode; provided by user.
---@field private original_keymaps table The keymaps to restore when exiting the mode; generated automatically.
local Layer = require('libmodal/src/utils/classes').new(nil)

---The Layers constructor
---@param keymappings table the keymaps of the form:
---```lua
---{
---	n = {
---		gg = { 'G', {silent = true} }
---	}
---}
---```
---@return libmodal.Layer
function Layer.new(keymappings)

	for _ --[[mode]], keymaps in pairs(keymappings) do
		for lhs, map in pairs(keymaps) do
			-- For backward compability.
			-- Convert from
			--   { n = { gg = { rhs = 'G', silent = true } } }
			-- into
			--   { n = { gg = { 'G', {silent = true} } } }
			if map.rhs then
				keymaps[lhs] = { extract_key_from_tbl('rhs', map), map }
			end

			-- Normalise lhs-es
			-- ----------------
			-- In the output of the `nvim_get_keymap` and `nvim_buf_get_keymap`
			-- functions some keycodes are replaced, for example: `<leader>` and
			-- some are not, like `<Tab>`.  So to avoid this incompatibility better
			-- to apply `termcodes` function on both `lhs` and the received keymap
			-- before comparison.
			local normalized_lhs = termcodes(lhs)
			if normalized_lhs ~= lhs then
				keymaps[normalized_lhs] = map
				keymaps[lhs] = nil
			end
		end
	end

	return setmetatable({
		active = false,
		layer_keymaps = keymappings,
		original_keymaps = {}
	}, Layer)
end

function Layer:save_original_keymaps()
	for mode, keymaps in pairs(self.layer_keymaps) do
		self.original_keymaps[mode] = self.original_keymaps[mode] or {}

		for _, map in ipairs(vim.api.nvim_buf_get_keymap(0, mode)) do
			map.lhs = termcodes(map.lhs)
			if keymaps[map.lhs] and not self.original_keymaps[mode][map.lhs] then
				self.original_keymaps[mode][map.lhs] = {
					rhs = map.rhs or '',
					expr = map.expr == 1,
					callback = map.callback,
					noremap = map.noremap == 1,
					script = map.script == 1,
					silent = map.silent == 1,
					nowait = map.nowait == 1,
					buffer = true,
				}
			end
		end

		for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
			map.lhs = termcodes(map.lhs)
			if keymaps[map.lhs] and not self.original_keymaps[mode][map.lhs] then
				self.original_keymaps[mode][map.lhs] = {
					rhs = map.rhs or '',
					expr = map.expr == 1,
					callback = map.callback,
					noremap = map.noremap == 1,
					script = map.script == 1,
					silent = map.silent == 1,
					nowait = map.nowait == 1,
					buffer = false,
				}
			end
		end
	end

	-- To avoid of adding into self.original keymaps table already remapped keys
	-- on Layer:map method execution.
	for mode, keymaps in pairs(self.layer_keymaps) do
		for lhs, _ in pairs(keymaps) do
			if not self.original_keymaps[mode][lhs] then
				self.original_keymaps[mode][lhs] = true
			end
		end
	end
end

--- apply the `Layer`'s keymaps buffer.
function Layer:enter()
	assert(not self.active, 'This layer has already been entered. `:exit()` before entering again.')
	self.active = true

	-- Populate a list of keymaps which will be overwritten to `original_keymaps`.
	self:save_original_keymaps()

	-- Apply the layer's keymappings.
	for mode, new_keymaps in pairs(self.layer_keymaps) do
		for lhs, new_keymap in pairs(new_keymaps) do
			if type(new_keymap) == 'string' or type(new_keymap) == 'function' then
				vim.keymap.set(mode, lhs, new_keymap)
			elseif type(new_keymap) == 'table' then
				vim.keymap.set(mode, lhs, unpack(new_keymap))
			else
				error('The value assigned to "lhs" should be either "string" or "function" or "table"')
			end
		end
	end
end

---add a keymap to the mode.
---@param mode string
---@param lhs string
---@param rhs function|string
---@param opts table
---@see `:help vim.keymap.set`
function Layer:map(mode, lhs, rhs, opts)
	lhs = termcodes(lhs)
	-- add the new mapping to the layer's keymap
	if opts then
		self.layer_keymaps[mode][lhs] = { rhs, opts }
	else
		self.layer_keymaps[mode][lhs] = rhs
	end

	if self.active then -- the layer has been activated
		self:save_original_keymaps()
		vim.keymap.set(mode, lhs, rhs, opts)
	end
end

--- restore one keymapping to its original state.
--- @param mode string the mode of the keymap.
--- @param lhs string the keys which invoke the keymap.
--- @see `vim.api.nvim_del_keymap`
function Layer:unmap(mode, lhs)
	lhs = termcodes(lhs)

	if self.active then
		if type(self.original_keymaps[mode][lhs]) == 'table' then
			-- there is an older keymap to go back to, so undo this layer_keymap
			local map = self.original_keymaps[mode][lhs]
			if map.buffer then
				local bufnr = vim.api.nvim_get_current_buf()
				vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, map.rhs, {
					expr = map.expr,
					callback = map.callback,
					noremap = map.noremap,
					script = map.script,
					silent = map.silent,
					nowait = map.nowait
				})
			else
				vim.api.nvim_set_keymap(mode, lhs, map.rhs, {
					expr = map.expr,
					callback = map.callback,
					noremap = map.noremap,
					script = map.script,
					silent = map.silent,
					nowait = map.nowait
				})
			end
		else
			-- just make the keymap go back to default
			local no_errors, err = pcall(vim.api.nvim_del_keymap, mode, lhs)

			if not no_errors and err ~= 'E31: No such mapping' then
				print(err)
			end
		end

		-- remove this keymap from the list of ones to restore
		self.original_keymaps[mode][lhs] = nil
	end

	self.layer_keymaps[mode][lhs] = nil
end

--- exit the layer, restoring all previous keymaps.
function Layer:exit()
	assert(self.active, 'This layer has not been entered yet.')

	for mode, keymaps in pairs(self.layer_keymaps) do
		for lhs, _ in pairs(keymaps) do
			self:unmap(mode, lhs)
		end
	end
	self.original_keymaps = {}
	self.active = false
end

return Layer.new
