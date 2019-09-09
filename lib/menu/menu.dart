import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:maplaos/menu/menu_login.dart';
import 'package:maplaos/menu/menu_sigined.dart';
import 'package:maplaos/model/alert.dart';
import 'package:maplaos/setting/setting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mysql1/mysql1.dart' as mysql;

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  Dio dio = new Dio();
  Setting setting = Setting();
  bool islogin = false;
  String first_name;
  String last_name;
  void checklogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('userId');
    if (userId != null) {
      var conn;
      try {
        conn = await mysql.MySqlConnection.connect(mysql.ConnectionSettings(
            host: setting.host,
            port: setting.port,
            user: setting.user,
            password: setting.password,
            db: setting.db,
            timeout: Duration(seconds: 5)));
            var userlogin =
                await conn.query('select * from user where id=?', [userId]);
            for (var user in userlogin) {
              var profiles =await conn.query('select * from profile where id=?', [user['profile_id']]);
              for (var profile in profiles) {
                setState(() {
                  photo_profile=profile['photo'];
                  photo_bg=profile['bg'];
                  first_name=profile['first_name'];
                  last_name=profile['last_name'];
                });
              }
            }
      } on Exception {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return Alert();
            });
      }
      
      setState(() {
        userID = userId;
        islogin = true;
      });
    }
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('userId');
    Navigator.of(context).pop();
  }

/* ------------------------ Upload Ingage profile -------------------------*/
  File _image;
  var photo_profile;
  bool isloadimg = false;
  File _imageBg;
  bool isloadimgBg = false;
  var photo_bg;
  int userID;
  Future getImageProfile(var type) async {
    var conn;
    try {
      conn = await mysql.MySqlConnection.connect(mysql.ConnectionSettings(
          host: setting.host,
          port: setting.port,
          user: setting.user,
          password: setting.password,
          db: setting.db,
          timeout: Duration(seconds: 5)));
    } on Exception {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Alert();
          });
    }
    var imageFile = (type == 'camera')
        ? await ImagePicker.pickImage(source: ImageSource.camera)
        : await ImagePicker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      setState(() {
        _image = imageFile;
        isloadimg = true;
      });
      /*============ Drop Images =================*/
      File croppedFile = await ImageCropper.cropImage(
          sourcePath: imageFile.path,
          ratioX: 1.0,
          ratioY: 1.0,
          toolbarTitle: 'Crop photo',
          toolbarColor: Colors.red);
      if (croppedFile != null) {
        imageFile = croppedFile;
        /*============ Send Images to API Save =================*/
        FormData formData = new FormData.from({
          "name": "profile_img",
          'edit': true,
          'userid': userID,
          "upfile": new UploadFileInfo(imageFile, "upload1.jpg")
        });
        try {
          var response =
              await dio.post("${setting.apiUrl}api/uplaodfile", data: formData);
          if (response.statusCode == 200) {
            var userlogin =
                await conn.query('select * from user where id=?', [userID]);
            var profile_id;
            for (var user in userlogin) {
              profile_id = user['profile_id'];
            }
            var results = await conn.query(
                'UPDATE profile SET photo =? where id = ?',
                [response.data.toString(), profile_id]);
            setState(() {
              isloadimg = false;
              photo_profile = response.data;
            });
          } else {
            print('Error upload image');
          }
        } on DioError catch (e) {
          print('Errors upload');
        }
      } else {
        setState(() {
          if (photo_profile.photo == null) {
            _image = null;
          }
          isloadimg = false;
        });
      }
    }
  }

/*====================== Uplaod image profile Bg ========================*/

  Future getImageBgProfile(var type) async {
    var conn;
    try {
      conn = await mysql.MySqlConnection.connect(mysql.ConnectionSettings(
          host: setting.host,
          port: setting.port,
          user: setting.user,
          password: setting.password,
          db: setting.db,
          timeout: Duration(seconds: 5)));
    } on Exception {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Alert();
          });
    }
    var imageBgFile = (type == 'camera')
        ? await ImagePicker.pickImage(source: ImageSource.camera)
        : await ImagePicker.pickImage(source: ImageSource.gallery);
    if (imageBgFile != null) {
      setState(() {
        _imageBg = imageBgFile;
        isloadimgBg = true;
      });
      /*============ Drop Images =================*/
      File croppedFile = await ImageCropper.cropImage(
          sourcePath: imageBgFile.path,
          ratioX: 1.8,
          ratioY: 1.0,
          toolbarTitle: 'Crop photo',
          toolbarColor: Colors.red);
      if (croppedFile != null) {
        imageBgFile = croppedFile;
        /*============ Send Images to API Save =================*/
        Dio dio = new Dio();
        FormData formData = new FormData.from({
          "name": "profileBg_img",
          'edit': true,
          'userid': userID,
          "upfile": new UploadFileInfo(imageBgFile, "upload1.jpg")
        });
        try {
          var response =
              await dio.post("${setting.apiUrl}api/uplaodfile", data: formData);
          if (response.statusCode == 200) {
            var userlogin =
                await conn.query('select * from user where id=?', [userID]);
            var profile_id;
            for (var user in userlogin) {
              profile_id = user['profile_id'];
            }
            var results = await conn.query(
                'UPDATE profile SET bg =? where id = ?',
                [response.data.toString(), profile_id]);
            setState(() {
              isloadimgBg = false;
              photo_bg = response.data;
            });
          } else {
            print('Error upload image');
          }
        } on DioError catch (e) {
          print('Errors upload bg');
        }
      } else {
        setState(() {
          if (photo_bg == null) {
            _imageBg = null;
          }
          isloadimgBg = false;
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checklogin();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            onDetailsPressed: () {
              showDialog(
                  context: context,
                  child: AlertDialog(
                      content: Container(
                    height: 80.0,
                    child: Column(
                      children: <Widget>[
                        Text(
                          'ປ່ຽນ​ຮູບ​ໂປ​ຣ​ໄຟພື້ນຫຼັງ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: <Widget>[
                            OutlineButton.icon(
                              label: Text('GALLERY',
                                  style: TextStyle(
                                      fontSize: 10.0, color: Colors.black)),
                              icon: Icon(
                                Icons.image,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                getImageBgProfile('gallery');

                                Navigator.of(context).pop();
                              },
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: OutlineButton.icon(
                                label: Text('CAMERA',
                                    style: TextStyle(fontSize: 10.0)),
                                icon: Icon(
                                  Icons.camera,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  getImageBgProfile('camera');

                                  Navigator.of(context).pop();
                                },
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )));
            },
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: photo_bg == null
                      ? AssetImage('assets/bg.jpg')
                      : NetworkImage('${setting.urlimg}/${photo_bg}'),
                  fit: BoxFit.fill),
            ),
            currentAccountPicture: GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      child: AlertDialog(
                          content: Container(
                        height: 80.0,
                        child: Column(
                          children: <Widget>[
                            Text(
                              'ປ່ຽນ​ຮູບ​ໂປ​ຣ​ໄຟ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: <Widget>[
                                OutlineButton.icon(
                                  label: Text('GALLERY',
                                      style: TextStyle(
                                          fontSize: 10.0, color: Colors.black)),
                                  icon: Icon(
                                    Icons.image,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    getImageProfile('gallery');

                                    Navigator.of(context).pop();
                                  },
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 10.0),
                                  child: OutlineButton.icon(
                                    label: Text('CAMERA',
                                        style: TextStyle(fontSize: 10.0)),
                                    icon: Icon(
                                      Icons.camera,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      getImageProfile('camera');

                                      Navigator.of(context).pop();
                                    },
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      )));
                },
                child: CircleAvatar(
                  backgroundImage: photo_profile == null
                      ? AssetImage('assets/user.png')
                      : NetworkImage('${setting.urlimg}/${photo_profile}'),
                )),
            accountName: Text(
              '$first_name',
              style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            accountEmail: Text(
              '$last_name',
              style: TextStyle(color: Colors.white),
            ),
          ),
          islogin ? MenuSigined() : MenuLogin(),
          ListTile(
            leading: Icon(
              Icons.assessment,
              color: Colors.blue,
            ),
            title: Text(
              'ວິ​ທີ​ນຳ​ໃຊ້',
              style: TextStyle(fontSize: 20.0),
            ),
            subtitle: Text(
              '​How to use',
              style: TextStyle(fontSize: 12.0),
            ),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(
              Icons.settings_applications,
              color: Colors.blue,
            ),
            title: Text(
              'ກ່ຽວ​ກັບເຮົາ',
              style: TextStyle(fontSize: 20.0),
            ),
            subtitle: Text(
              'about us​',
              style: TextStyle(fontSize: 12.0),
            ),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {},
          ),
          Divider(),
          islogin?ListTile(
            trailing: Icon(
              Icons.settings_power,
              color: Colors.red,
            ),
            title: Text(
              'ອອກ​ຈາກ​ລະ​ບົບ',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            onTap: () {
              logout();
            },
          ):Text(''),
        ],
      ),
    );
  }
}
