-- Imports
local libmodal = require 'libmodal'

-- create a new layer.
local layer = libmodal.layer.new(
{
	n =
	{ -- normal mode mappings
		gg = -- remap `gg`
		{
			rhs = 'G', -- map it to `G`
			-- other options such as `noremap` and `silent` can be set to `true` here
		},
		G = -- remap `G`
		{
			rhs = 'gg', -- map it to `gg`
			-- other options such as `noremap` and `silent` can be set to `true` here
		},
	}
})

-- Add an additional mapping for `<Esc>` to exit the mode
layer:map('n', '<Esc>', function() layer:exit() end, {})

layer:enter()

--[[ unmap `gg`. Notice that now both `gg` and `G` return the cursor to the top. ]]
layer:unmap('n', 'gg')
