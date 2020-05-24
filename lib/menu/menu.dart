import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:maplaos/menu/menu_login.dart';
import 'package:maplaos/menu/menu_sigined.dart';
import 'package:maplaos/model/about_us.dart';
import 'package:maplaos/model/alert.dart';
import 'package:maplaos/model/how_us.dart';
import 'package:maplaos/setting/setting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
          var profiles = await conn
              .query('select * from profile where id=?', [user['profile_id']]);
          for (var profile in profiles) {
            setState(() {
              photo_profile = profile['photo'];
              photo_bg = profile['bg'];
              first_name = profile['first_name'];
              last_name = profile['last_name'];
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
         aspectRatioPresets:[
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ],
              androidUiSettings: AndroidUiSettings(
                toolbarTitle: 'Cropper',
                toolbarColor: Colors.deepOrange,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false),
              );
      if (croppedFile != null) {
        imageFile = croppedFile;
        /*============ Send Images to API Save =================*/
        FormData formData = new FormData.fromMap(
            {
               "filepost": await MultipartFile.fromFile(imageFile.path,filename: "upload.jpg")
               }
        );
        /*FormData formData = new FormData.from(
            {"filepost": new UploadFileInfo(imageFile, "upload1.jpg")});*/
        try {
          var response = await dio.post("${setting.apiUrl}/uploadfile",
              data: formData, options: Options(method: 'POST'));
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
          print(e);
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
          aspectRatioPresets:[
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ],
              androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
              );
      if (croppedFile != null) {
        imageBgFile = croppedFile;
        /*============ Send Images to API Save =================*/
        Dio dio = new Dio();
        FormData formData = new FormData.fromMap(
            {
              "filepost": await MultipartFile.fromFile(imageBgFile.path,filename: "upload.jpg")
             // "filepost": new UploadFileInfo(imageBgFile, "upload1.jpg")
              }
        );
        /*FormData formData = new FormData.from(
            {"filepost": new UploadFileInfo(imageBgFile, "upload1.jpg")});*/
        try {
          var response = await dio.post("${setting.apiUrl}/uploadfile",
              data: formData, options: Options(method: 'POST'));
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
    return  Drawer(
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
                          Text(('Change Backgroud').tr(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: <Widget>[
                              OutlineButton.icon(
                                label: Text(('GALLERY').tr(),
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
                                  label: Text(('CAMERA').tr(),
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
                        : NetworkImage('${setting.apiUrl}/showimg/${photo_bg}'),
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
                              Text(("Change Profile").tr(),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: <Widget>[
                                  OutlineButton.icon(
                                    label: Text(('GALLERY').tr(),
                                        style: TextStyle(
                                            fontSize: 10.0,
                                            color: Colors.black)),
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
                                      label: Text(('CAMERA').tr(),
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
                        : NetworkImage(
                            '${setting.apiUrl}/showimg/${photo_profile}'),
                  )),
              accountName: Text(
                first_name == null ? '' : '$first_name',
                style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              accountEmail: Text(
                first_name == null ? '' : '$last_name',
                style: TextStyle(color: Colors.white),
              ),
            ),
            islogin ? MenuSigined() : MenuLogin(),
            ListTile(
              leading: Icon(
                Icons.assessment,
                color: Colors.red,
              ),
              title: Text(("How to use").tr(),
                style: TextStyle(fontSize: 16.0),
              ),
              subtitle: Text(("How to use this app").tr(),
                style: TextStyle(fontSize: 12.0),
              ),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HowUs(),
                    ));
              },
            ),
            ListTile(
              leading: Icon(
                Icons.settings_applications,
                color: Colors.red,
              ),
              title: Text(("About Us").tr(),
                style: TextStyle(fontSize: 16.0),
              ),
              subtitle: Text(("Explain about us").tr(),
                style: TextStyle(fontSize: 12.0),
              ),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AboutUs(),
                    ));
              },
            ),
            ExpansionTile(
              leading: Icon(
                Icons.settings,
                color: Colors.red,
              ),
              title: Text(('Setting').tr(),
                style: TextStyle(fontSize: 16.0),
              ),
              children: <Widget>[
                ListTile(
                  leading: Icon(
                    Icons.language,
                    color: Colors.red,
                  ),
                  title: Text(('Switch Language').tr(),
                    style: TextStyle(fontSize: 12.0),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              this.setState(() {
                                context.locale = Locale('lo', 'LA'); // switch lenguage
                              });
                            },
                            child: Image.asset(
                              'assets/la.png', // On click should redirect to an URL
                              width: 10.0,
                              height: 10.0,
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              this.setState(() {
                                context.locale = Locale('en', 'US'); // switch lenguage
                              });
                            },
                            child: Image.asset(
                              'assets/en.png', // On click should redirect to an URL
                              width: 10.0,
                              height: 10.0,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  trailing: Icon(Icons.keyboard_arrow_right),
                ),
                islogin
                    ? ListTile(
                        leading: Icon(
                          Icons.settings_power,
                          color: Colors.red,
                        ),
                        trailing: Icon(Icons.keyboard_arrow_right),
                        title: Text(("Logout").tr(),
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        onTap: () {
                          logout();
                        },
                      )
                    : Text(''),
              ],
            ),
          ],
        ),
      );
  }
}
