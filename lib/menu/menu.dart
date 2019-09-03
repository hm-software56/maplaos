import 'package:flutter/material.dart';
import 'package:maplaos/menu/menu_login.dart';
import 'package:maplaos/menu/menu_sigined.dart';
import 'package:maplaos/setting/setting.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  Setting setting = Setting();
  var photo_bg;
  var photo_profile;
  bool islogin = false;
  void checklogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('userId');
    if (userId != null) {
      setState(() {
        islogin = true;
      });
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
                                //getImageBgProfile('gallery');

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
                                  // getImageBgProfile('camera');

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
                                    //getImageProfile('gallery');

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
                                      // getImageProfile('camera');

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
              'Daxiong',
              style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            accountEmail: Text(
              'SONGYANGCHENG',
              style: TextStyle(color: Colors.white),
            ),
          ),
          islogin?MenuSigined():MenuLogin(),
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
          ListTile(
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
              //logOut();
            },
          ),
        ],
      ),
    );
  }
}
