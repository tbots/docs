" This script is the usage example of the "s:" prefix that declares a variable local to the script.
" another_scount.vim is:
" let s:count=10
" Even after it is sourced the value of s:count defined in this script is not changed
let s:count=1
while s:count < 5
	source another_scount.vim
	echo s:count
	let s:count += 1
endwhile
