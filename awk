
 awk -F= '/UnitFileState/ {if ($2 == "enabled") printf "enabled %s\n", $unit; else if ...

 NR     # line number
