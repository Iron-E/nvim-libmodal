" Register key commands and what they do.
let s:barModeKeymaps = {
\	'': 'echom "You cant exit using escape."',
\	'q': 'let g:barModeExit = 1'
\}

" Tell the mode not to exit automatically.
let g:barModeExit = 0

" Enter the mode using the keymaps created before.
call libmodal#Enter('BAR', s:barModeKeymaps, 1)
