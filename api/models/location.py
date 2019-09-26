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
    def textsearch(self):
        db=config.connect_db()
        cur=db.cursor()
        location_name=[]
        cur.execute("select DISTINCT(name) from location_search")
        for location in cur.fetchall():
            location_name.append(location[0])
        cur.execute("update location_searchs set search_text=%s",(str(location_name),))
        db.commit()
        cur.close()
        return jsonify('true')