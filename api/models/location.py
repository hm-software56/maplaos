from flask import jsonify
from config import conn
class Location:
    def __init__(self):
        self.cur=conn.cursor()
        self.name='Location'
        
        
    def loadimg( self, id):
        self.cur.execute("select photo from photo where location_id=%s",(id,))
        rv = self.cur.fetchall()
        photos=[]
        for data in rv:
            photos.append(data[0])
        return  jsonify(photos)