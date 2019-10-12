let c=1
while c < 10
	echo "c:" c
	let c += 1
	"source another_count.vim			" cause an endless loop, due to reinitialization of the variable
	source another_scount.vim			" reinitialization is not happening because variable prefixed with s: is 
                                " local to it's buffer
endwhile
