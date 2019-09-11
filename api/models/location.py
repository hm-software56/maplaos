from flask import jsonify
from config import conn
class Location:
    def loadimg(id):
        cur = conn.cursor()
        cur.execute("select photo from photo where location_id=%s",(id,))
        conn.commit()
        rv = cur.fetchall()
        photos=[]
        for data in rv:
            photos.append(data[0])
        return  jsonify(photos)