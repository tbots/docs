import sys

elements = ''
for element in sys.argv[1:]:			# note elements access
    elements += element

print(elements)
