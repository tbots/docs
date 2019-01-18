awk -v FS=';' -v NUM_NODES=$2 -v SPLICE_COL=$3 -v OUT_FILE=$4 '\
BEGIN {\
  start = systime();\
  if(NUM_NODES=="" || SPLICE_COL==""){print "null or empty number of nodes or column to splice by"; exit 1}\
  if(OUT_FILE==""){OUT_FILE="file";}\
}\
{\
  node = timeToNode($SPLICE_COL); \
  print $0 > OUT_FILE node;\
}\
END {print "elapsed time: " systime() - start;} \
function timeToNode(date,      t) { #t je lokalna premenna\
  t=date; \
  gsub("-", " ",t); \
  gsub(":", " ",t); \
  gsub("\"", "",t); \
  #pridany retazec " 0 0 0", aby to fungovalo pre date; pre datetime by to malo fungovat aj tak \
  t = mktime(t " 0 0 0")/60/60/24; \
  return int(t)%NUM_NODES; \
} \
' \
$1
