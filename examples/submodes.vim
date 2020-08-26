let s:fooModeRecurse = 1

function! s:fooMode() abort
	let l:userInput = nr2char(g:foo{s:fooModeRecurse}ModeInput)

	if l:userInput == 'z'
		let s:fooModeRecurse += 1
		call s:enter()
		let s:fooModeRecurse -= 1
	endif
endfunction

function! s:enter() abort
	call luaeval("require('libmodal').mode.enter('FOO'.._A, 's:fooMode')", s:fooModeRecurse)
endfunction

call s:enter()
