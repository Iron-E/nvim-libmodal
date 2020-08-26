let s:inputHistory = []

function! s:clear(indexToCheck) abort
	if len(s:inputHistory) > a:indexToCheck
		for i in range(len(s:inputHistory))
			let s:inputHistory[i] = v:null
		endfor
	endif
endfunction

function! s:fooMode() abort
	let s:inputHistory = add(s:inputHistory, nr2char(g:fooModeInput))

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

lua require('libmodal').mode.enter('FOO', 's:fooMode')
