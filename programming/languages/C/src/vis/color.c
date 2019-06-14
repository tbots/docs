#include <stdio.h>

int main() {
	printf("Previous character matched:\n");
	printf("\033[41m\033[97mAAA\033[0m\n");		/* B: Red; F: White */

	printf("Non-printable character:\n");
	printf("[\033[90m\\n\033[0m]\n");

	printf("Current character read:\n");
	printf("\033[7mAAA\033[0m\n");		/* set color for the current character read */
	return 0;
}
