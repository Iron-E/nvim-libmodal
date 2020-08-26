let s:commandList = ['new', 'close', 'last']

function! s:fooMode() abort
	let l:userInput = g:fooModeInput
	if userInput == 'new'
		tabnew
	elseif userInput == 'close'
		tabclose
	elseif userInput == 'last'
		tablast
	endif
endfunction

call luaeval("require('libmodal').prompt.enter('FOO', 's:fooMode', _A)", s:commandList)
