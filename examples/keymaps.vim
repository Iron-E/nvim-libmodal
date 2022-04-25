" Register keymaps for splitting windows and then closing windows
let s:barModeKeymaps = {
\	'zf': 'split',
\	'zfo': 'vsplit',
\	'zfc': 'q'
\}

" Enter the mode using the keymaps.
call libmodal#Enter('BAR', s:barModeKeymaps)
