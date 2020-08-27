" This is the list of commands— used for auto completion.
let s:commandList = ['new', 'close', 'last']

" This function will be called whenever a command is entered.
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

" You have to convert s:commandList from a Vimscript list to a lua table using luaeval().
call luaeval("require('libmodal').prompt.enter('FOO', 's:fooMode', _A)", s:commandList)
