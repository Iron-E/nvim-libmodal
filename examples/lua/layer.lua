local libmodal = require('libmodal')

-- create a new layer.
local layer = libmodal.Layer.new({
	['n'] = { -- normal mode mappings
		['gg'] = { -- remap `gg`
			['rhs'] = 'G', -- map it to `G`
			['noremap'] = true, -- don't recursively map.
		},
		['G'] = { -- remap `G`
			['rhs'] = 'gg', -- map it to `gg`
			['noremap'] = true -- don't recursively map.
		}
	}
})

-- enter the `layer`.
layer:enter()

-- add a global function for exiting the mode.
function libmodal_layer_example_exit()
	layer:exit()
end

-- Add an additional mapping for `z`.
layer:map('n', 'z', 'gg', {['noremap'] = true})

-- add an additional mapping for `q`.
layer:map(
	'n', 'q', ':lua libmodal_layer_example_exit()<CR>',
	{['noremap'] = true, ['silent']  = true}
)

--[[ unmap `gg` and `G`. Notice they both return to their defaults,
     rather than just not doing anything anymore. ]]
layer:unmap('n', 'gg')
layer:unmap('n', 'G')

-- If you wish to only change the mappings of a layer temporarily, you should use another layer. `map` and `unmap` permanently add and remove from the layer's keymap.
