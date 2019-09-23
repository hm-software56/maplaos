from flask import jsonify
import config
class User:
    def __init__(self):
        self.name="User"
        
    def listuser(self):
        db=config.connect_db()
        cur=db.cursor()
        cur.execute("select * from user")
        cur.close()
        rv = cur.fetchall()
        return  jsonify(rv)