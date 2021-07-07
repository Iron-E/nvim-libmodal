-- Imports
local libmodal = require('libmodal')

-- create a new layer.
local exitFunc = libmodal.layer.enter({
	n = { -- normal mode mappings
		gg = { -- remap `gg`
			rhs = 'G', -- map it to `G`
			noremap = true, -- don't recursively map.
		},
		G = { -- remap `G`
			rhs = 'gg', -- map it to `gg`
			noremap = true -- don't recursively map.
		}
	}
})

-- The layer will deactivate in 5 seconds for this demo.
vim.loop.new_timer():start(5000, 0, vim.schedule_wrap(
	function() exitFunc(); print('EXITED.') end
))
