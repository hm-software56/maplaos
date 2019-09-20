from flask import jsonify
from config import conn
class User:
    def __init__(self):
        self.name="User"
        
    def listuser(self):
        cur=conn.cursor()
        cur.execute("select * from user")
        cur.close()
        rv = cur.fetchall()
        return  jsonify(rv)