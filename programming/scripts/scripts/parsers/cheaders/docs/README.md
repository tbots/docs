 Cheaders.sh - Writes required headers and include statements into C source files.

 Three main actions are supported:

 	1. List. All the files that declares functions are found recursively and listed.
	2. Create header. Creates header for the function declarations found in the source files.
	3. Write include statement and headers. Writes include statements into source files found recursively.
		 Creates header file for the all function declarations found.

 Globals:

 	FN
	CMD_ARGS

 Arrays:

  files
	headers
	decarations
	lines
	dfile

 Functions:

 	find_lhdr		  find local header that declares function

								INPUT:		header
								RETURN:		headers[]
	
	chck_lhdr			check header file for duplicity in headers array

								INPUT:		header, headers[]
								RETURN:		headers[]

	find_df				find file that 

	find_hdr

	inc_wr

	header_wr
	
	find_inc		

	get_man

	get_inc
								INPUT:		
								RETURN:		headers[]

	find_dl

	inc_wr

	header_wr

	list


	TODO:

	Write out expressions used in script.
	Issue cann't find printf function with fn.sh.


	Expressions:

		First uncommented line
		Function declaration within man file
			line=`grep --max-count=1 --line-number $man -e "^[^a-z]*\([a-z_*]\+\s*\)\{1,2\}\<$fn\>\s*([^)]\+\();\)\?" | awk -F: '{print $1}'`

			sed -n '/\<\(while\|main\|if\|else\)\>/! s/^\s*\(\w\+\>\)\s*\(\**\)\s*\([a-zA-Z_]\+\)\s*\((.*)\)\s*{\?\s*$/\1 \2\3\4;/p' $file
