class Dog():
    """A simple attempt to model a Dog"""

    def __init__(self,name,age):
        """Initialize name and age |attributes|"""
        self.name = name
        self.age = age
				print("My dog age: " + str(self.age) + ".")
				print("My dog age: %d." % self.age)
    
    def sit(self):
        """Simulate a dog sitting in response to a command"""
        print(self.name.title() + " is now sitting!")

    def roll_over(self):
        """Simulate a dog rolling over in response to a command"""
        print(self.name.title() + " rolled over!")

dog = Dog('zebra',2)

print("My dog name: " + dog.name.title() + ".")

dog.sit()
dog.roll_over() 
