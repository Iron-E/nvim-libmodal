let s:commands = {
\	'new': 'tabnew',
\	'close': 'tabclose',
\	'last': 'tablast'
\}

call libmodal#Prompt('TAB', s:commands)
