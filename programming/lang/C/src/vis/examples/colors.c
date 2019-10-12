#include <stdio.h>

void display_used_color
	(char *esc_code, char *text)	{

	char *reset_color = "\033[0m";
	if ( ! *text ) text = "TEST";		// set default text to "TEST" if description was not provided
	printf("%s%s%s%s",
					reset_color,
					esc_code,
					text,
					reset_color);
	printf("%s\n", text);
}

int main() {
	
	display_used_color("\033[7m","current character");		/* set color for the current character read */
	display_used_color("\033[41m\033[97m","matched character");
	display_used_color("\033[90m","");

	return 0;
}
