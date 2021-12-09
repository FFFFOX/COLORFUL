from flask import Flask, render_template, request, Response, jsonify, redirect, url_for
from flask_cors import CORS
from gevent import pywsgi
import json
import cv2
import numpy
import base64
import os
import time
import fd



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
        # with open('pic.txt', 'w') as f:
        #     f.writelines(data)
        print("**json**")
        str_image = json_data.get("imgData")
        img = base64.b64decode(str_image[0])
        # print(str_image)


        img_np = numpy.frombuffer(img, dtype='uint8')

        new_img_np = cv2.imdecode(img_np, 1)
        # cv2.imshow("1",new_img_np)




        # # new_img_np = cv2.imdecode(img_np, cv2.IMREAD_COLOR)
        # print(new_img_np)
        # T = time.time()
        cv2.imwrite('./rev_images/111.jpg', new_img_np)

        with open('test.png','rb') as f:
            # bs = str(base64.b64encode(f.read()))
            bs = f.read()

        
    # return jsonify({'code': 201, 'id': bs})
    # return jsonify({'img': bs})
    return bs

@app.route('/receiveImage/', methods=["GET","POST"])
def receive_image():
    # value = 201
    if request.method == "POST":
        data = request.data.decode('utf-8')
        json_data = json.loads(data)
        str_image = json_data.get("imgData")
        img = base64.b64decode(str_image)
        img_np = numpy.frombuffer(img, dtype='uint8')
        # img_np = numpy.frombuffer(img, numpy.uint8)
        print(img_np)
        new_img_np = cv2.imdecode(img_np, 1)
        # new_img_np = cv2.imdecode(img_np, cv2.IMREAD_COLOR)
        print(new_img_np)
        T = time.time()
        cv2.imwrite('./rev_images/rev_image.jpg', new_img_np)
        print('data:{}'.format('success'))
        fd_value = fd.face("./images/","./rev_images/rev_image.jpg")
        print("**************************")
        print(fd_value)
        print("**************************")
        with open('test.png','rb') as f:
            bs = str(base64.b64encode(f.read()))

        if fd_value != "unknown" and fd_value != "":
            print("情况1")
            print(fd_value)
            print("**************************")
            # value = 200
            return jsonify({'code': 200, 'id': fd_value})
        else:
            print("情况2")
            print(fd_value)
            print("**************************")
            print(bs)
            return jsonify({'code': 201, 'id': bs})
    elif request.method == "GET":
        return Response('<center><h1>捕获</h1></center>'
                        '<h1>ceshi</h1>')

if __name__ == '__main__':
    server = pywsgi.WSGIServer(('0.0.0.0', 5000), app)
    server.serve_forever()
    app.run(debug=True)

    # app.run()
    # app.run(debug=False, host='https://www.aibrief.ink/', port=5000)