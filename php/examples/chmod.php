<?php

# Change file mode example

#var_dump("$_SERVER[DOCUMENT_ROOT]/test_file.txt");
var_dump(chmod("/var/www/html/test_file.txt",0766));
print_r(error_get_last());
