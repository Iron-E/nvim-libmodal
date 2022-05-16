" Create a new layer.
let s:layer = {
\	'n': {
\		'gg': {
\			'rhs': 'G',
\			'noremap': v:true,
\		},
\		'G': {
\			'rhs': 'gg',
\			'noremap': v:true
\		}
\	}
\}

" Capture the exit function
let s:exitFunc = luaeval("require('libmodal').layer.enter(_A, '<Esc>')", s:layer)
