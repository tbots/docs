import sys

try :
    name = str(sys.argv[1])

except :
    print('fuck')
    sys.exit(1)

print(name.title())
