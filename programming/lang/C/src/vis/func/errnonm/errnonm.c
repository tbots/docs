/* Returns a pointer to the flag name corresponding to the value. */
char *errnonm(int value) {
	char *label;
	label = ec_malloc(20);
	errnonm_r(label,value);
	return label;
}
