from flask import jsonify
from config import conn
class User:
    def __init__(self):
        self.cur=conn.cursor()
        self.name="User"
        
    def listuser(self):
        self.cur.execute("select * from user")
        rv = self.cur.fetchall()
        return  jsonify(rv)