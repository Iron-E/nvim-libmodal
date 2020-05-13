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

" SUMMARY:
" * Get user input with some `completions`.
" PARAMS:
" * `indicator` => the prompt string.
" * `completions` => the list of completions to provide.
" RETURNS:
" * Input from `input()`.
function! libmodal#_inputWith(indicator, completions)
	" TODO: 0.5 — return input(a:indicator, '', 'customlist,v:lua.require("libmodal/src/prompt")…')
	" return the closure that was generated using the completions from lua.
	function! LibmodalCompletionsProvider(argLead, cmdLine, cursorPos) abort closure
		return luaeval(
		\	'require("libmodal/src/prompt/")._createCompletionsProvider(_A[1])(_A[2], _A[3], _A[4])',
		\	[a:completions, a:argLead, a:cmdLine, a:cursorPos]
		\)
	endfunction

	echohl LibmodalStar
	return input(a:indicator, '', 'customlist,LibmodalCompletionsProvider')
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
function! libmodal#_winOpen(bufHandle) abort
	return nvim_open_win(a:bufHandle, 0, s:winOpenOpts)
endfunction
