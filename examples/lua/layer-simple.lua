local libmodal = require 'libmodal'

-- create a new layer
libmodal.layer.enter(
	{
		n = { -- normal mode mappings
			gg = { -- remap `gg`
				'G', -- map it to `G`
				{ noremap = true }, -- don't recursively map
			},
			G = { -- remap `G`
				'gg', -- map it to `gg`
				{ noremap = true } -- don't recursively map
			}
		}
	},
	'<Esc>'
)

-- the layer will deactivate when you press <Esc>
