import sys

elements = ''
for element in sys.argv[1:]:
    elements += element.title() + " "

print(elements)
