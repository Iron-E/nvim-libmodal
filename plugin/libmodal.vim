if exists('g:loaded_libmodal')
	finish
endif
let g:loaded_libmodal = 1

if !exists('g:libmodalTimeouts')
	let g:libmodalTimeouts = &timeout
endif

" ************************************************************
" * User Configuration
" ************************************************************

" The default highlight groups (for colors) are specified below.
" Change these default colors by defining or linking the corresponding highlight group.
highlight default link LibmodalPrompt ModeMsg
highlight default link LibmodalStar StatusLine
