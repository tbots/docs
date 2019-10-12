let v = "syntax_on"
echo "value of v:" v

let v = "syntax_x"
if exists("v")
  echo v." is set and it's value is non-zero"
else
  echo v." is not set"
endif
