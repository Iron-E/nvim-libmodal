" Recurse counter.
let s:barModeRecurse = 0

" Register 'z' as the map for recursing further (by calling the BarMode function again).
let s:barModeKeymaps = {
\	'z': 'BarModeEnter',
\}

" define the BarMode() function which is called whenever the user presses 'z'
function! s:BarMode()
	let s:barModeRecurse += 1
	call libmodal#Enter('BAR' . s:barModeRecurse, s:barModeKeymaps)
	let s:barModeRecurse -= 1
endfunction

" Call BarMode() initially to begin the demo.
command! BarModeEnter call s:BarMode()
execute 'BarModeEnter'
