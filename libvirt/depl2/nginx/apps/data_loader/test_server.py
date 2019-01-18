import requests


import os
import time

json_ = open('test_full.txt').readline()

load = {'upload_hash': os.urandom(20).encode('hex'), 'project_id':'pj_e92a8743436541f650225784ee58becb','err_email': ['']}

load['data'] =   json_
load["timestamp"] = time.strftime("%Y-%m-%d %H:%M:%S")  
print time.time()
r = requests.post('http://10.140.48.102:5000/upload_json', json = load)
print time.time()
print r.json()


# r = requests.get('http://127.0.0.1:5000/upload_json')
# 
# print r.text




# payload = {'key1': 'value1', 'key2': 'value2'}
# r = requests.get("http://127.0.0.1:5000/test", params=payload)
