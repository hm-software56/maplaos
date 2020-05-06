from flask import jsonify
import config
import numpy as np
import matplotlib.pyplot as plt
import os
# matplotlib.use('Agg')
# from matplotlib.pyplot import plot as plt
from datetime import timedelta, date


class Location:
    def __init__(self):
        self.name = 'Location'

    def loadimg(self, id):
        db = config.connect_db()
        cur = db.cursor()
        cur.execute("select photo from photo where location_id=%s", (id,))
        cur.close()
        rv = cur.fetchall()
        photos = []
        for data in rv:
            photos.append(data[0])
        return jsonify(photos)

    def textsearch(self):
        db = config.connect_db()
        cur = db.cursor()
        location_name = []
        cur.execute("select DISTINCT(name) from location_search")
        for location in cur.fetchall():
            location_name.append(location[0])
        cur.execute("update location_searchs set search_text=%s",
                    (str(location_name),))
        db.commit()
        cur.close()
        return jsonify('true')

    def generatechart(self):
        db = config.connect_db()
        cur = db.cursor()
        Current_Date = date.today()
        Start_Date = Current_Date + timedelta(days=-6)
        delta = Current_Date - Start_Date

        cur.execute(
            "SELECT DISTINCT(location_id) as location_id FROM tracking_visitor WHERE date(date)>=%s and date(date)<=%s",
            (str(Start_Date.strftime("%Y-%m-%d")), str(Current_Date.strftime("%Y-%m-%d"))))
        for location in cur.fetchall():
            data = []
            dates = []
            StartDate = Start_Date
            delta1 = timedelta(days=1)
            location_id = location[0]
            while StartDate <= Current_Date:
                count = cur.execute("SELECT * FROM tracking_visitor WHERE location_id=%s and date(date)=%s",
                                    (location_id, StartDate.strftime("%Y-%m-%d")))
                data.append(int(count))
                dates.append(StartDate.strftime("%Y-%m-%d"))
                StartDate += delta1
            days = (tuple(dates))
            y_pos = np.arange(len(days))
            plt.rcParams['axes.spines.right'] = False
            plt.rcParams['axes.spines.top'] = False
            plt.figure(figsize=(10, 4))
            plt.plot(y_pos, data, color='r')
            plt.title("ສະຖິຕິ/Statistics", fontname="Phetsarath OT", fontweight='bold', fontsize=20)
            plt.xticks(y_pos, days)
            plt.xticks(rotation=45)
            plt.savefig('/home/cbr/python/api/images/' + str(location_id) + '.png', bbox_inches="tight")
            # plt.savefig('D:/Projectmobile/maplaos/api/images/'+str(location_id)+'.png',bbox_inches = "tight")
            plt.close()
        cur.close()
        return jsonify('true')
