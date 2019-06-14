#!/bin/bash
#
# Escaping is a method of quoting single characters. The escape (\) preceding a character tells the shell to 
# interpret that character literally.

# With certain commands and untilities, such as echo and sed, escaping a character may have the opposite 
# effect - it can toggle on a special meaning for that character.

# Special meanings of certain escaped characters
# used with echo and sed
#
#		\n
#					new line
#
#		\r
#					return
#
#		\t
#					means tab
#
#		\v
#					vertical tab
#
#		\b		
#					backspace
#
#		\a
#					alert (beep or flash)
#
#		\0xx
#					translates to the octal ASCII equivalent of 0nn, where nn is a string of digits.
#
# The $' ... ' quoted string expansion construct is a mechanism that uses escaped octal or 
# hex values to assign ASCII characters to variables, e.g., quote=$'\042'
