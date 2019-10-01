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
  List listphoto=List();
  bool isloding=true;
  void loadingImg() async {
      Response response = await Dio(BaseOptions(
      )).get('${setting.apiUrl}/loadimg/${location_id}');
      for (var data in response.data) {
        listphoto.add(data);
      }
      setState(() {
        listphoto=listphoto;
       isloding=false; 
      });
    
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
          for (var photo in listphoto) 
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: '${setting.apiUrl}/showimg/$photo',
                placeholder: (context, url) =>
                    new Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => new Icon(Icons.error),
              ),
            ),
          ),
          
        ]);
  }
}
