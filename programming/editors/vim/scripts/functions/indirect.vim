function! Inc(j)
	let a:j+=1
	return a:j
endf

let i=3
call Inc(i)
echo "i:" i
