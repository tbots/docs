#!/bin/bash
#
#

DICT="$HOME"/.dict		# Dictionary file.
TMP="$HOME"/.tmp 			# Temporary tmp file.
HELL=/dev/null				# No return location.
EOF=0									# End of file indicator.

echo -n "Enable learning mode? [Y/n]: "; read ANS
if [[ "$ANS" =~ [Yy]([EeSs]$)?$|^$ ]]		# <ENTER> or yes (ignore case).
then
	echo "Searching any previously saved words for missing translations..."
	FILE_SIZE=$( wc -l $DICT | cut -d\  -f1 )		# File size.
	LINE=$FILE_SIZE
	while [ "$LINE" -gt "$EOF" ]
	do	
		# Read a line.
		WORD=$( tail -n$LINE $DICT | head -n1 | grep -e '\w\+\([ \t]\+$\)\?$' )
		let "(( OFFSET = $FILE_SIZE - $LINE ))"
		let "(( LINE = $LINE -1 ))"

		if [ -n "$WORD" ]
		then
			head -n $OFFSET $DICT > $TMP		# Store the portion $DICT above the reading line in $TMP.
			echo -n $WORD\    ; read TSL		# Translation prompt. All whitespace are suppressed.

			if [[ "$TSL" =~ [Rr]([EeMmOoVvEe]$)? ]]
			# Remove the entry from the dictionary file.
			then
				tail -n$LINE $DICT >> $TMP
			elif [[ "$TSL" =~ [Ee]([DdIiTt]$)?$ ]]
			# Modify the word before prompting for a translation.
			then
				echo -n "Edit the word or press ENTER for the default [$WORD]: ";
				read TSL

				if [ -n "$TSL" ]
				# <ENTER>
				then
					WORD=$TSL
				fi
				
				echo -n "Enter a translation for the $WORD: " ; read TSL		
				echo "$WORD   $TSL" >> $TMP			# Append translated line at the end of $TMP.
				tail -n $LINE $DICT >> $TMP 		# Append portion of $DICT below the reading line to $TMP.
				mv $TMP $DICT										# Rewrite $DICT
				tail -n $LINE $DICT >> $TMP
			else
			fi
		fi
	done
	echo "Done."

													### Start translation of the new words ###

	echo -n "Enter a word: "; read WORD
	while [ -n "$WORD" ] 
	do
		grep "$DICT" -e ^$WORD || {		# Word is not found in dictionary.

			echo "No match found. Learn the word? [Y/n] " 
			read ANS

			# Answer is not recognized.
			while [[ ! "$ANS" =~ [Yy]([EeSs]$)?$|[Nn]([Oo]$)?$|^$ ]]
			do
				echo -n "Answer was not recognized." >&2
				echo -n "Learn the word? [Y/n] "; read ANS
			done

			if [[ "$ANS" =~ [Yy]([EeSs]$)?$|^$ ]]
			then
				echo -n "Edit the word to learn, or press ENTER for the default [$WORD]: "
				read ANS
			
				# Initialize the word with the new value.
				if [ -n "$ANS" ] 
				then
					WORD=$ANS 
				fi

				echo -n "Enter a translation for a '$WORD': "; read TSL
				echo "$WORD   $TSL" >> $DICT
			
				echo "Stored '$WORD'."
			fi;
		}
	done
# No previous or new translations will be prompted. 
else	
	echo "DEBUG: The answer read is $ANS"

	echo -n "Enter a word: "; read WORD
	while [ -n "$WORD" ] 
	do
		grep "$DICT" -e ^$WORD || {		# Word is not found in dictionary.

			echo -n "No match found. Learn mode is disabled, store the word for the future translations? [Y/n] " 
			read ANS

			# Answer is not recognized.
			while [[ ! "$ANS" =~ [Yy]([EeSs])?|[Nn]([Oo])?|^$ ]]
			do
				echo -n "Answer was not recognized." >&2
				echo -n "Learn the word? [Y/n] "; read ANS
			done

			if [[ "$ANS" =~ [Yy]([EeSs])?|^$ ]]
			then
				echo -n "Edit the word to store, or press ENTER for the default [$WORD]: "
				read ANS
			
				if [ -n "$ANS" ] 
				# Initialize the word with the new value.
				then
					WORD=$ANS 
				fi
				echo "$WORD" >> $DICT
				echo "Stored '$WORD'."
			fi;
		}
	# New word prompt.
	echo -n "Enter a word: "; read WORD
	done
fi

# Sort on exit.
sort $DICT > $TMP && mv $TMP $DICT
