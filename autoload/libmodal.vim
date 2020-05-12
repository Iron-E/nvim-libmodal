let libmodal#_replacements = [
\	'.', ':', '&', '@', ',', '\\/', '?',
\	'(', ')',
\	'{', '}',
\	'[', ']',
\	'+', '\\*', '\\!', '\\^', '\\>', '\\<', '%', '=',
\	'\\$',
\	'\\'
\]

let libmodal#_winOpenOpts = {
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
" * Provide completions for a `libmodal.prompt`.
" PARAMS:
" * `completions` => the list of completions.
" RETURNS:
" * A function that accepts:
" 	* `argLead` => the current line being edited, stops at the cursor.
" 	* `cmdLine` => the current line being edited
" 	* `cursorPos` => the position of the cursor
function! libmodal#CreateCompletionsProvider(completions)
	function! l:completionsProvider(argLead, cmdLine, cursorPos) abort closure
		" replace conjoining characters with spaces.
		let l:spacedArgLead = a:argLead
		for l:replacement in s:replacements
			let l:spacedArgLead = substitute(l:spacedArgLead, l:replacement, ' ', 'g')
		endfor

		" split the spaced version of `argLead`.
		let l:splitArgLead = split(splitArgLead, ' ')

		" make sure the user is in a position were this function
		"     will provide accurate completions.
		if len(splitArgLead) > 1 | return v:none | end

		" get the word selected by the user.
		let l:word = l:splitArgLead[1]

		" get all matches from the completions list.
		let l:completions = []
		for l:completion in s:completions
			if stridx(l:completion, l:word) > -1
				let l:completions = add(l:completions, l:completion)
			endif
		endfor
		return l:completions
	endfunction

	return funcref('l:completionsProvider')
endfunction

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
	return nvim_open_win(a:bufHandle, 0, libmodal#_winOpenOpts)
endfunction
