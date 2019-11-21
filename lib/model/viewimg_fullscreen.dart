import 'package:flutter/material.dart';
import 'package:maplaos/setting/setting.dart';
import 'package:photo_view/photo_view.dart';

class ViewIMGFullSceen extends StatelessWidget {
  var photoname;
  ViewIMGFullSceen(this.photoname);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: PhotoView(
            backgroundDecoration: BoxDecoration(color: Colors.white),
            imageProvider: NetworkImage(
              '${Setting().apiUrl}/showimg/$photoname',
              scale: 1.0,
            )),
      ),
    );
  }
}
