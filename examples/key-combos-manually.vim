" Keep track of the user's input history manually.
let s:inputHistory = []

" Clear the input history if it grows too long for our usage.
function! s:clear(indexToCheck) abort
	if len(s:inputHistory) > a:indexToCheck
		for i in range(len(s:inputHistory))
			let s:inputHistory[i] = v:null
		endfor
	endif
endfunction

" This is the function that will be called whenever the user presses a button.
function! s:fooMode() abort
	" Append to the input history, the latest button press.
	let s:inputHistory = add(s:inputHistory, nr2char(g:fooModeInput)) " The input is a character number.

	" Custom logic to test for each character index to see if it matches the 'zfo' mapping.
	let l:index = 0
	if s:inputHistory[0] == 'z'
		if get(s:inputHistory, 1, v:null) == 'f'
			if get(s:inputHistory, 2, v:null) == 'o'
				echom 'It works!'
			else
				let l:index = 2
			endif
		else
			let l:index = 1
		endif
	endif

	call s:clear(l:index)
endfunction

" Enter the mode to begin the demo.
lua require('libmodal').mode.enter('FOO', 's:fooMode')
