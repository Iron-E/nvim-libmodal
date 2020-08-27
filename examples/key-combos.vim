" Register key combos for splitting windows and then closing windows
let s:barModeCombos = {
\	'zf': 'split',
\	'zfo': 'vsplit',
\	'zfc': 'q'
\}

" Enter the mode using the key combos.
call libmodal#Enter('BAR', s:barModeCombos)
