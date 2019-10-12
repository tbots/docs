			case '[':	
	

				if(exp[++temp_t] == '^') 
					negotiate_match = ++temp_t;

				nb = temp_t + 1;	/* next bracket pointer */
					
				do {
			
					if(exp[nb] 	 == '-') {		/* range */
						nb++;		/* next character in range */
						if(exp[nb] == ']') {		/* '[abcd-]' */
								fprintf(stderr, "Incompleted range specification in `%s'\n", exp);
								exit(EXIT_FAILURE);
						}
			
						c = exp[temp_t];
						if(c == cs.c)
							matched_in_word++;		
						else {
							do { 
								if(++c == cs.c) {	
									matched_in_word++;
									break;
								}
							} while(c != exp[nb]);	
						}
						
						temp_t = ++nb; ++nb;
					}
					else 
					if(exp[temp_t] == cs.c)	/* exact match */
						matched_in_word++; 	

					temp_t = nb++;
						
					if(matched_in_word) {
						if(negotiate_match)  	matched_in_word = 0;
						break;
					}
				}
				while(exp[temp_t] != ']');

