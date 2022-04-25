" SUMMARY:
" * Runs the nvim-libmodal command prompt loop. The function takes an optional
"   argument specifying how many times to run (runs until exiting by default).
" PARAMS:
" * `a:1` => `modeName`
" * `a:2` => `modeCallback` OR `modeKeymaps`
" * `a:3` => `supressExit`
function! libmodal#Enter(...) abort
	call libmodal#_lua('mode', a:000)
endfunction

" SUMMARY:
" * Runs the nvim-libmodal command prompt loop. The function takes an optional
"   argument specifying how many times to run (runs until exiting by default).
" PARAMS:
" * `a:1` => `modeName`
" * `a:2` => `modeCallback` OR `modeCommands`
" * `a:3` => `modeCompletions`
function! libmodal#Prompt(...) abort
	call libmodal#_lua('prompt', a:000)
endfunction

" SUMMARY:
" * Pass arguments to an nvim-libmodal `enter()` command at the specified
"   `lib` path.
" PARAMS:
" * `lib` => the name of the library.
"      * 'mode" or 'prompt'.
" * `args` => the arguments to pass to `lib`.enter()
function! libmodal#_lua(lib, args)
	call luaeval(
	\	'require("libmodal").' . a:lib . '.enter(_A[1], _A[2], _A[3])',
	\	[
	\		a:args[0],
	\		a:args[1],
	\		get(a:args, 2, v:null)
	\	]
	\)
endfunction
