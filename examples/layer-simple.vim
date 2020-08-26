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
let s:exitFunc = luaeval("require('libmodal').layer.enter(_A)", s:layer)

" Call the exit function in 5 seconds.
call timer_start(5000, s:exitFunc)
