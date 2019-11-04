import http.client
import json
conn = http.client.HTTPSConnection("fcm.googleapis.com")
json_data= {
        "to": "/topics/all",
        "priority":"high",
        "notification":{
            "title":"Test daxiong11111",
            "body":"Test123222222222222",
            "click_action":"FLUTTER_NOTIFICATION_CLICK"}
            }
payload = json.dumps(json_data)
headers = {
    'authorization': "key=AAAANdRVapM:APA91bE2fGusYtnZMm1WAktXLJReJGYbPw0C83VLhLtWSpMUruzK-6tPgoMt5ZbmTEYmcwGoQwq-XeFkdLaoX918s1igxUh8LZCEzf6cRARtSlX3aM7EDdEZCY0yyDmoT2tZpOBBN6XY",
    'content-type': "application/json"
    }
conn.request("POST", "/fcm/send", payload, headers)

res = conn.getresponse()
data = res.read()

print(data.decode("utf-8"))