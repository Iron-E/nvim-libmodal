let s:commandList = ['new', 'close', 'last']

function! s:BarMode() abort
	if g:tabModeInput ==# 'new'
		execute 'tabnew'
	elseif g:tabModeInput ==# 'close'
		execute 'tabclose'
	elseif g:tabModeInput ==# 'last'
		execute 'tablast'
	endif
endfunction

call libmodal#Prompt('TAB', funcref('s:BarMode'), s:commandList)
