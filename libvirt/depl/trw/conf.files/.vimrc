set nocompatible
set number
set tabstop=2
set autoindent
set wrapmargin=10
syntax on

if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
	endif
