from flask import Flask, render_template, request, Response, jsonify, redirect, url_for
from flask_cors import CORS
from gevent import pywsgi
import json
import cv2
import numpy
import base64
import time
from recolor import Core



app = Flask(__name__)
CORS(app, supports_credentials=True)


@app.route('/')
def hello_world():
    return Response('<center><h1>捕获</h1></center>'
                    '<h1>ceshi</h1>')


@app.route('/video_sample/')
def video_sample():
    return render_template('camera.htm')

@app.route('/test/')
def test():
    return render_template('test.htm')

@app.route('/iosTest/', methods=["GET","POST"])
def iosTest():
    if request.method == "POST":

        data = request.data.decode('utf-8')

        json_data = json.loads(data)

        print("**post received**")
        str_image = json_data.get("imgData")
        img = base64.b64decode(str_image[0])

        img_np = numpy.frombuffer(img, dtype='uint8')

        new_img_np = cv2.imdecode(img_np, 1)

        T = time.time()
        cv2.imwrite('./rev_images/pic_{}.jpg'.format(T), new_img_np)
        # Core.correct(input_path='./rev_images/pic_{}.jpg'.format(T),
        #              return_type='save',
        #              save_path='./rev_images/correct_pic_{}.jpg'.format(T),
        #              protanopia_degree=0.0,
        #              deuteranopia_degree=1.0)
        Core.simulate(input_path='./rev_images/pic_{}.jpg'.format(T),
                      return_type='save',
                      save_path='./rev_images/correct_pic_{}.jpg'.format(T),
                      simulate_type='deuteranopia',
                      simulate_degree_primary=0.9)
        with open('./rev_images/correct_pic_{}.jpg'.format(T),'rb') as f:
            # bs = str(base64.b64encode(f.read()))
            bs = f.read()

        # print("")


    # return jsonify({'code': 201, 'id': bs})
    # return jsonify({'img': bs})
    return bs


if __name__ == '__main__':
    server = pywsgi.WSGIServer(('0.0.0.0', 5100), app)
    server.serve_forever()
    app.run(debug=True)

    # app.run()
    # app.run(debug=False, host='https://www.aibrief.ink/', port=5000)