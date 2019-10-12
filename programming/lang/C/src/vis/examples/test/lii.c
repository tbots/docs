/*
 * Return last index in x[].
 */
int li(int x[]) {
	int i;
	for(i=1; x[i] != 0; i++)
		;
	return i;
}
