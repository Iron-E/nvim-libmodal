" This is a counter.
let s:fooModeRecurse = 1

" This is a function to increase the counter every time that 'z' is pressed.
function! s:fooMode() abort
	let l:userInput = nr2char(g:foo{s:fooModeRecurse}ModeInput)

	if l:userInput == 'z'
		let s:fooModeRecurse += 1
		call s:enter()
		let s:fooModeRecurse -= 1
	endif
endfunction

" This function wraps around calling libmodal so that the other function can recursively call it.
function! s:enter() abort
	call luaeval("require('libmodal').mode.enter('FOO'.._A, 's:fooMode')", s:fooModeRecurse)
endfunction

" Begin the recursion.
call s:enter()
