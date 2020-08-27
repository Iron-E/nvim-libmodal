" Function which is called every time the user presses a button.
function! s:fooMode() abort
	let l:userInput = nr2char(g:fooModeInput)

	if l:userInput == ''
		echom 'You cant leave using <Esc>.'
	elseif l:userInput == 'q'
		let g:fooModeExit = v:true
	endif
endfunction

" Tell the mode not to exit automatically.
let g:fooModeExit = v:false
" Begin the mode.
lua require('libmodal').mode.enter('FOO', 's:fooMode', true)
