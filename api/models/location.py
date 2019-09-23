from flask import jsonify
import config
class Location:
    def __init__(self):
        self.name='Location'
        
        
    def loadimg(self, id):
        db=config.connect_db()
        cur=db.cursor()
        cur.execute("select photo from photo where location_id=%s",(id,))
        cur.close()
        rv = cur.fetchall()
        photos=[]
        for data in rv:
            photos.append(data[0])
        return  jsonify(photos)