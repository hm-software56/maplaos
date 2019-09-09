import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:maplaos/model/model_login.dart';
import 'package:maplaos/setting/setting.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:rich_alert/rich_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModelProfile extends StatefulWidget {
  @override
  _ModelProfileState createState() => _ModelProfileState();
}

class _ModelProfileState extends State<ModelProfile> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  Setting setting = Setting();
  bool isloading = false;
  bool isloadinit = true;
  var first_name;
  var last_name;
  var email;
  var phone;
  var username;
  var password;
  void loadprofile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('userId');
    final conn = await mysql.MySqlConnection.connect(mysql.ConnectionSettings(
        host: setting.host,
        port: setting.port,
        user: setting.user,
        password: setting.password,
        db: setting.db));
    var profiles = await conn.query('select * from user left join profile on profile.id=user.profile_id where user.id=?', [userId]);
    for(var profile in profiles){
      setState(() {
        isloadinit=false;
        first_name=profile['first_name'];
        last_name=profile['last_name'];
        email=profile['email'];
        phone=profile['phone'];
        username=profile['username'];
        password=profile['password'];
      });
    }
  }

  void editprofile() async {
    setState(() {
      isloading = true;
    });
    final conn = await mysql.MySqlConnection.connect(mysql.ConnectionSettings(
        host: setting.host,
        port: setting.port,
        user: setting.user,
        password: setting.password,
        db: setting.db));
    var data = _fbKey.currentState.value;
    var saveprofile = await conn.query(
        'insert into profile (first_name, last_name, email,phone) values (?, ?, ?, ?)',
        [data['first_name'], data['last_name'], data['email'], data['phone']]);
    if (saveprofile.insertId != null) {
      var saveuser = await conn.query(
          'insert into user (username, password, status,type,profile_id) values (?, ?, ?, ?, ?)',
          [
            data['username'],
            md5.convert(utf8.encode(data['password'])).toString(),
            1,
            'user',
            saveprofile.insertId
          ]);
      if (saveuser.insertId != null) {
        setState(() {
          isloading = false;
        });
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return RichAlertDialog(
                //uses the custom alert dialog
                alertTitle: richTitle("ສຳ​ເລັດ/Successed"),
                alertSubtitle:
                    richSubtitle("ກົດ​ປຸ່ມ​ຂ້າງ​ລຸ່ມ​/Click button below"),
                alertType: RichAlertType.SUCCESS,
                actions: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.border_all,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ModelLogin(),
                          ));
                    },
                  )
                ],
              );
            });
      }
    }
  }
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadprofile();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          'ບັນ​ທືກ/Save',
          textAlign: TextAlign.center,
        )),
      ),
      body: isloadinit?Center(child: CircularProgressIndicator(),): ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FormBuilder(
              key: _fbKey,
              autovalidate: true,
              child: Column(
                children: <Widget>[
                  FormBuilderTextField(
                    attribute: "first_name",
                    initialValue:'$first_name',
                    decoration: InputDecoration(labelText: "ຊື່/First name"),
                    validators: [
                      FormBuilderValidators.required(
                          errorText:
                              'ທ່ານ​ຕ້ອງ​ປ້ອນ​ຊື່/Please enter first name'),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                  ),
                  FormBuilderTextField(
                    attribute: "last_name",
                    initialValue:'$last_name',
                    decoration:
                        InputDecoration(labelText: "​ນາມ​ສະ​ກຸນ/Last name"),
                    validators: [
                      FormBuilderValidators.required(
                          errorText:
                              'ທ່ານ​ຕ້ອງ​ປ້ອນ​​ນາມ​ສະ​ກຸນ/Please enter last name'),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                  ),
                  FormBuilderTextField(
                    attribute: "email",
                    initialValue:'$email',
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: "ອີ​ເມວ/Email"),
                    validators: [
                      FormBuilderValidators.max(255),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                  ),
                  FormBuilderTextField(
                    attribute: "phone",
                    initialValue:'$phone',
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(labelText: "ເບີ​ໂທ/Phone"),
                    validators: [
                      FormBuilderValidators.required(
                          errorText:
                              'ທ່ານ​ຕ້ອງ​ປ້ອນ​​ເບີ​ໂທ/Please enter phone number'),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                  ),
                  Divider(),
                  FormBuilderTextField(
                    attribute: "username",
                    initialValue:'$username',
                    decoration:
                        InputDecoration(labelText: "ຊື່​ເຂົ້າ​ລະ​ບົບ/Username"),
                    validators: [
                      FormBuilderValidators.required(
                          errorText:
                              'ທ່ານ​ຕ້ອງ​ປ້ອນ​​ຊື່​ເຂົ້າ​ລະ​ບົບ/Please enter username'),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                  ),
                  FormBuilderTextField(
                    attribute: "password",
                    initialValue:'$password',
                    obscureText: true,
                    decoration:
                        InputDecoration(labelText: "ລະ​ຫັດ​ຜ່ານ/Password"),
                    validators: [
                      FormBuilderValidators.required(
                          errorText:
                              'ທ່ານ​ຕ້ອງ​ປ້ອນ​​ລະ​ຫັດ​ຜ່ານ/Please enter password'),
                      FormBuilderValidators.min(4,
                          errorText:
                              'ລະ​ຫັດ​ຜ່ານ​ຕ້ອງ​ມີ 4 ໂຕ​ຂື້ນ​ໄປ/Password must contain 4 or more digits'),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                  ),
                  FormBuilderTextField(
                    attribute: "password_confirm",
                    initialValue:'$password',
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: "ຢືນ​ຢັນ​ລະ​ຫັດ/Password confirm"),
                    validators: [
                      FormBuilderValidators.required(),
                      (val) {
                        if (_fbKey.currentState.fields['password'].currentState
                                .value !=
                            val) {
                          return "ຢືນ​ຢັນ​ລະ​ຫັດ​ບໍ່​ຖືກ​ຕ້ອງ​/Password confirm is incorect";
                        }
                      }
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: isloading
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : RaisedButton.icon(
                                icon: Icon(
                                  Icons.save,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  '​ສົ່ງ/Submit',
                                  style: TextStyle(color: Colors.white),
                                ),
                                key: null,
                                onPressed: () {
                                  if (_fbKey.currentState.saveAndValidate()) {
                                    editprofile();
                                  }
                                },
                                color: Colors.red,
                              ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
