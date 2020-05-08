let s:barModeRecurse = 0

function! s:BarMode()
	if g:bar{s:barModeRecurse}ModeInput ==# 'z'
		let s:barModeRecurse += 1
		execute 'BarModeEnter'
		let s:barModeRecurse -= 1
	endif
endfunction

command! BarModeEnter call libmodal#Enter('BAR' . s:barModeRecurse, funcref('s:BarMode'))
execute 'BarModeEnter'
