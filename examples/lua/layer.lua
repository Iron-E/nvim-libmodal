local libmodal = require 'libmodal'

-- create a new layer
local layer = libmodal.layer.new({
	n = { -- normal mode mappings
		gg = { -- remap `gg`
			'G', -- map it to `G`
			-- The table with other options suitable for vim.keymap.set can be passed here.
		},
		G = { -- remap `G`
			'gg', -- map it to `gg`
			-- The table with other options suitable for vim.keymap.set can be passed here.
		},
	}
})

-- add an additional mapping for `<Esc>` to exit the mode
layer:map('n', '<Esc>', function() layer:exit() end, {})

layer:enter()

--[[ unmap `gg`. Notice that now both `gg` and `G` return the cursor to the top. ]]
layer:unmap('n', 'gg')
