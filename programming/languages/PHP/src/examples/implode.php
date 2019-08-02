#string implode([string $field_separator,] array $arr); 

$str1 = implode(', ', $arr3);   # "one, two, three" 
                                #      ^ notice the space
var_dump($str1);

$str2 = implode($arr3);
var_dump($str2);        # "onetwothree"
