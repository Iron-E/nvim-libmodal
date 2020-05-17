let s:barModeCombos = {
\	'': 'echom "You cant exit using escape."',
\	'q': 'let g:barModeExit = 1'
\}

let g:barModeExit = 0
call libmodal#Enter('BAR', s:barModeCombos, 1)
