function generate_mac ()  {
  hexchars="0123456789abcdef"
  echo "24:df:86$(
    for i in {1..6}; do 
      echo -n ${hexchars:$(( $RANDOM % 16 )):1}
    done | sed -e 's/\(..\)/:\1/g'
  )"
}

generate_mac
