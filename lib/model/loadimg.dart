import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:maplaos/setting/setting.dart';

class Loadimg extends StatefulWidget {
  var location_id;
  Loadimg(this.location_id);
  @override
  _LoadimgState createState() => _LoadimgState(this.location_id);
}

class _LoadimgState extends State<Loadimg> {
  var location_id;
  _LoadimgState(this.location_id);

  Setting setting = Setting();
  var photo1;
  var photo2;
  bool isloding=true;
  void loadingImg() async {
    try {
      Response response = await Dio(BaseOptions(
        connectTimeout: 5000,
        receiveTimeout: 5000,
      )).get('${setting.apiUrl}/api/loadimg&id=${location_id}');
      int i = 0;
      for (var data in response.data) {
        i = i + 1;
        if (i == 1) {
          setState(() {
           photo1 = '${setting.urlimg}/${data}'; 
          });
        } else {
         setState(() {
           photo2 = '${setting.urlimg}/${data}'; 
         });
        }
      }
      setState(() {
       isloding=false; 
      });
    } catch (e) {
      print(e);
    }
  }

void initState() { 
  super.initState();
  loadingImg();
}
  @override
  Widget build(BuildContext context) {
    return isloding? Center(child: CircularProgressIndicator(),) :Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                height: 150,
                imageUrl: photo1,
                placeholder: (context, url) =>
                    new Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => new Icon(Icons.error),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                height: 150,
                imageUrl: photo2,
                placeholder: (context, url) =>
                    new Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => new Icon(Icons.error),
              ),
            ),
          ),
          
        ]);
  }
}
