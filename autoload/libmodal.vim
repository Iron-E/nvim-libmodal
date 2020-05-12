let s:winOpenOpts = {
\	'anchor'   : 'SW',
\	'col'      : &columns - 1,
\	'focusable': v:false,
\	'height'   : 1,
\	'relative' : 'editor',
\	'row'      : &lines - &cmdheight - 1,
\	'style'    : 'minimal',
\	'width'    : 25,
\}

" PLACEHOLDER.
function! libmodal#Enter(...) abort
	echo ''
endfunction

" PLACEHOLDER.
function! libmodal#Prompt(...) abort
	echo ''
endfunction

" SUMMARY:
" * Open a floating window using native vimscript.
" REMARKS:
" * There are bugs with creating floating windows using Lua (mostly they are
"   always focused), so it was necessary to create a vimscript method.
" PARAMS:
" * `bufHandle` => the buffer to spawn the window for.
" RETURNS:
" * A window handle.
function! libmodal#WinOpen(bufHandle) abort
	return nvim_open_win(a:bufHandle, 0, s:winOpenOpts)
endfunction
