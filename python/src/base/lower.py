import sys

try:
    name = str(sys.argv[1])

except:
    sys.exit(1)

print(name.lower())
