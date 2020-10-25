import os, re, redis
from flask import Flask, jsonify, request

REDIS_HOST = os.environ['REDIS_HOST']
REDIS_PORT = os.environ['REDIS_PORT']
REDIS_DB = os.environ['REDIS_DB']
REDIS = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, db=REDIS_DB)
APP_PORT = int(os.environ['PORT'])
app = Flask('app server')

@app.route('/')
def index():
    return 'Hello World'


app.run(debug=True, host='0.0.0.0', port=APP_PORT)