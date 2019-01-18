script_file = open("create_script.sql")
new_script_file = open("create_script_empty.sql",'w+')

script_lines = script_file.readlines()

one_line_script = ''
for line in script_lines:
    if len(line):
        if "$function$" in line and "AS" not in line:
            one_line_script += line.replace('\n','') + ";"
        else:
            one_line_script += line.replace('\n','')
            
            
one_line_script = one_line_script.replace('STRICTAS','STRICT AS')
# one_line_script = one_line_script.replace("'${var1} week'","''${var1} week''")
# one_line_script = one_line_script.replace("'${var1} month'","''${var1} month''")
# one_line_script = one_line_script.replace("'${var1} year'","''${var1} year''")
one_line_script = one_line_script.replace('CREATE SCHEMA "public";','')
one_line_script = one_line_script.replace("'b0c5a21b734b4daff84fa1609a0b3de0', 0, '2015-02-13 10:11:31.514572', 1, null,","'b0c5a21b734b4daff84fa1609a0b3de0', 0, '2015-02-13 10:11:31.514572', True, null,")
one_line_script = one_line_script.replace("'b0c5a21b734b4daff84fa1609a0b3de0', 0, '2015-02-12 15:17:25.84217', 1, null,","'b0c5a21b734b4daff84fa1609a0b3de0', 0, '2015-02-13 10:11:31.514572', True, null,")



new_script_file.write(one_line_script)
print one_line_script
new_script_file.close()




