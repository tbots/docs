class Car(object):
    def __init__(self,make,model,year):
        self.make = make
        self.model = model
        self.year = year
        self.gas_tank = 0
        self.odometer_reading=0  # initial value, must have

    def get_descriptive_name(self):
        long_name = str(self.year) + ' ' + self.model + ' ' + self.make
        return long_name.title()

    def read_odometer(self):
        print("This car has " + str(self.odometer_reading) + " miles on it.")

    def read_gas_tank(self):
        print("Tank has " + str(self.gas_tank) + " liters")

    def update_odometer(self,mileage):
        if mileage >= self.odometer_reading:
            self.odometer_reading = mileage
        else:
            print("You can not rollback an odometer!")

    def increment_odometer(self,miles):
        self.odometer_reading += miles

    def fill_gas_tank(self,amount):
        self.gas_tank += amount



class ElectricCar(Car):
    """ Reperesents aspects of a car related to electric vehicles """
     
    def __init__(self,make,model,year):
        """ Initialize attributes of the parent class """
        super(ElectricCar, self).__init__(make,model,year)
        self.battery = Battery()
    
    def read_gas_tank(self):
        print("Error to read gas: electric car")

    def fill_gas_tank(self):
        print("Error to fill gas: electric car")

class Battery(object):
    """ Battery attributes for electric car """
    def __init__(self,battery_size=70):
        self.battery_size = battery_size

    def describe_battery(self):
        """ Print a statement describing the battery size. """
        print("This car has a " + str(self.battery_size) + " -hWh battery.")


#car = Car('Audi', 'a6', 1986)
#print(car.get_descriptive_name())
#car.read_odometer()
#
#car.odometer_reading=23
#car.read_odometer()
#
#car.update_odometer(50)
#car.read_odometer()
#
#car.update_odometer(40)

tesla = ElectricCar('tesla', 'model s', 2016)
print(tesla.get_descriptive_name())
tesla.battery.describe_battery()

#car= Car("Audi", "Jo", 2012)
#car.fill_gas_tank(40)
#car.read_odometer()
#car.read_gas_tank()
