from flask import Flask
from flask import request
from flask import jsonify

app = Flask(__name__)

import load_data


@app.route('/upload_json', methods=['POST'])
def upload_json():
    if request.method == 'POST':
        post_data = request.get_json()
#         print post_data
        if post_data != None and len(post_data):
            load_res = load_data.upload_json_data(**post_data)
            print load_res
            if load_res != True:
                return jsonify(**load_res)
            else:
                return jsonify(result=True)

        else:
            return "No data"
    return "FU"
  
  
@app.route('/fu', methods=['GET'])
def test_get():
    if request.method == 'GET':
        return "TEST GET"
    return "FU"

if __name__ == "__main__":
    app.run(debug=True)#host='0.0.0.0'
    
