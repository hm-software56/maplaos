import os
from flask import Flask
app=Flask(__name__)
from routes.api import *
if __name__=="__main__":
    app.run(debug=True,threaded=True)