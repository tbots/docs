# 0 FALSE	1 TRUE

#from time import sleep
import serial
import time
import array
import string
import requests
import json

DEV="/dev/ttyS0"
#http://10.140.48.197:5000/store_data

port = serial.Serial(port = DEV,
					 baudrate = 115200,
					 #bytesize = {FIVEBITS|SIXBITS|SEVENBITS|EIGHTBITS},
					 #parity = {PARITY_NONE|PARITY_EVEN|PARITY_ODD|PARITY_MARK|PARITY_SPACE},
					 #stopbits = {STOPBITS_ONE|STOPBITS_ONE_POINT_FIVE|STOPBITS_TWO},
					 #timeout = ,			# read timeout
					 xonxoff = 0			# software flow control	 
					 #rtscts = , 			# hardware flow control (RTS/CTS)
					 #dsrdtr = , 			# hardware flow control (DSR/DTR)
					 #write_timeout = ,	
					 #inter_byte_timeout = ,		# inter-character timeout; None to disable (default)
					 )


def send_data(air_msg):
	try:
		requests.post('http://10.140.48.197:5000/store_data', json = air_msg)
	except requests.exceptions.ConnectionError:
		return False
	return True

air_msg = []
while True:
    #print len(air_msg)
    #print port.readline()
    try:
        sensor_data = port.readline()
    except Exception, err:
        print err 
        sensor_data = None    
    if not sensor_data:
        continue
    air_msg.append({'data':sensor_data,'time':time.strftime("%Y-%m-%d %H:%M:%S")})
	
    ret = send_data(air_msg)
    if ret == True:
		air_msg = []
    else:
		print "Connection refused, data buffered..."
