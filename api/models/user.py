from flask import jsonify
from config import conn
class User:
    def listuser():
        cur = conn.cursor()
        cur.execute("select * from user")
        conn.commit()
        rv = cur.fetchall()
        return  jsonify(rv)