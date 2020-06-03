import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:maplaos/home.dart';
import 'package:maplaos/model/model_register.dart';
import 'package:maplaos/setting/setting.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:easy_localization/easy_localization.dart';

class ModelLogin extends StatefulWidget {
  @override
  _ModelLoginState createState() => _ModelLoginState();
}

class _ModelLoginState extends State<ModelLogin> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  Setting setting = Setting();
  bool isloading = false;
  var error = '';
  @override
  void login() async {
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
    var userlogin = await conn.query(
        'select * from user where status=? and username=?',
        [1, data['username'].toString()]);
    if (userlogin.length != 0) {
      for (var user in userlogin) {
        if (md5.convert(utf8.encode(data['password'])).toString()==user['password'].toString()) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setInt('userId', int.parse(user['id'].toString()));
          prefs.setString('userType', user['type'].toString());
          Navigator.of(context).pop(); 
        } else {
          setState(() {
            error =
                "Username or password incorrect";
            isloading = false;
          });
        }
      }
    } else {
      setState(() {
        error =
            "Username or password incorrect";
        isloading = false;
      });
    }
    await conn.close();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
            icon: new Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop(); 
              /*Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Home(),
                  ));*/
            }),
        title: Center(
            child: Text("Login",
          textAlign: TextAlign.center,
        ).tr()),
      ),
      body: ListView(
        reverse: false,
        children: <Widget>[
          Container(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset('assets/logo.png'),
                  FormBuilder(
                    key: _fbKey,
                    autovalidate: true,
                    child: Column(
                      children: <Widget>[
                        FormBuilderTextField(
                          attribute: "username",
                          decoration:
                              InputDecoration(labelText:("Username").tr()),
                          validators: [
                            FormBuilderValidators.required(),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.all(20),
                        ),
                        FormBuilderTextField(
                          obscureText: true,
                          maxLines: 1,
                          attribute: "password",
                          decoration: InputDecoration(
                              labelText:("Password").tr()),
                          validators: [
                            FormBuilderValidators.required(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                  ),
                  error.toString() == 'null'
                      ? Padding(
                          padding: EdgeInsets.all(5),
                        )
                      : isloading ? Text('') : Text((error).tr().toString(),style:TextStyle(fontSize: 11,color: Colors.red),),
                  Padding(
                    padding: EdgeInsets.all(5),
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
                                  Icons.lock_open,
                                  color: Colors.white,
                                ),
                                label: Text("Login",
                                  style: TextStyle(color: Colors.white),
                                ).tr(),
                                key: null,
                                onPressed: () {
                                  if (_fbKey.currentState.saveAndValidate()) {
                                    login();
                                  }
                                },
                                color: Colors.red,
                              ),
                      )
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: ListTile(
                          leading: Icon(
                            Icons.spellcheck,
                            color: Colors.red,
                          ),
                          title: Align(
                              alignment: Alignment(-2, 0),
                              child: new Text("Register",
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ).tr()),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ModelRegister(),
                                ));
                          },
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: Align(
                              alignment: Alignment(1, 0),
                              child: new Text("Forget password",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ).tr()),
                          trailing: Icon(
                            Icons.error_outline,
                            color: Colors.red,
                          ),
                          onTap: () {
                            Navigator.of(context).pushNamed('/profile');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
