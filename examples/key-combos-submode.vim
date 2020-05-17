let s:barModeRecurse = 0

let s:barModeCombos = {
\	'z': 'BarModeEnter',
\}

function! s:BarMode()
	let s:barModeRecurse += 1
	call libmodal#Enter('BAR' . s:barModeRecurse, s:barModeCombos)
	let s:barModeRecurse -= 1
endfunction

command! BarModeEnter call s:BarMode()
execute 'BarModeEnter'
