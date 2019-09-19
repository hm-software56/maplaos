from flask import jsonify
from config import conn
class Location:
    def __init__(self):
        self.name='Location'
        
        
    def loadimg(self, id):
        cur=conn.cursor()
        cur.execute("select photo from photo where location_id=%s",(id,))
        rv = cur.fetchall()
        photos=[]
        for data in rv:
            photos.append(data[0])
        return  jsonify(photos)