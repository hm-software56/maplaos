import http.client
import json


class Pushnotification:
    def __init__(self):
        self.name = "Pushnotification"

    def sendnotification():
        conn = http.client.HTTPSConnection("fcm.googleapis.com")
        json_data = {
            "to": "/topics/all",
            "priority": "high",
            "notification": {
                "title": "ກວດ​​ຈັບສະ​ຖານ​ທີ່​ທ່ອງ​ທ​່ຽວ/Detection places tour",
                "body": "ເປິດ App ກວດ​ຈັບ​ສະ​ຖານ​ທີ່​ທ່ອງ​ທ່ຽວ​ທີ່​ໃກ້ທ່ານ \r Open App  check places tour near you",
                "click_action": "FLUTTER_NOTIFICATION_CLICK"}
        }
        payload = json.dumps(json_data)
        headers = {
            'authorization': "key=AAAANdRVapM:APA91bE2fGusYtnZMm1WAktXLJReJGYbPw0C83VLhLtWSpMUruzK-6tPgoMt5ZbmTEYmcwGoQwq-XeFkdLaoX918s1igxUh8LZCEzf6cRARtSlX3aM7EDdEZCY0yyDmoT2tZpOBBN6XY",
            'content-type': "application/json"
        }
        conn.request("POST", "/fcm/send", payload, headers)

        res = conn.getresponse()
        data = res.read()
        return data.decode("utf-8")
        # print(data.decode("utf-8"))
