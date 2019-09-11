from flask import jsonify
from config import conn
cur = conn.cursor()
class User:
    def listuser():
        cur.execute("select * from user")
        conn.commit()
        rv = cur.fetchall()
        return  jsonify(rv)