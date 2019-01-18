bicycles = ['trek', 'cannondale', 'redline', 'specialized' ]
print(bicycles)
print(bicycles[0])		# trek
print bicycles[0], bicycles[1] + "hello"

#print bicycles[-5]		# out of range		# out of range		# out of range		# out of range		# out of range

bicycles = 'coca-cola'

print(bicycles)				# cola-cola
print(bicycles[0]) 		# 'c' - not a list anymore

bicycles = ['trek', 'cannondale', 'redline', 'specialized' ]
print(bicycles)
bicycles[1] = 'black hawk'
print(bicycles)	
bicycles.append('bmw')
print(bicycles)	

bicycles.insert(1,'mercedes')		# inserts before
print(bicycles)

del bicycles[-1]
print(bicycles)

poped = bicycles.pop()
print(bicycles)
print(poped)

poped = bicycles.pop(1)
print(bicycles)
print(poped)

bicycles.insert(2,'bmw')
print(bicycles)

bicycles.remove('black hawk')
print(bicycles)
