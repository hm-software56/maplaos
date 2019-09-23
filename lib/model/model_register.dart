import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:maplaos/model/model_login.dart';
import 'package:maplaos/setting/setting.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:rich_alert/rich_alert.dart';
import 'package:easy_localization/easy_localization.dart';

class ModelRegister extends StatefulWidget {
  @override
  _ModelRegisterState createState() => _ModelRegisterState();
}

class _ModelRegisterState extends State<ModelRegister> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  Setting setting = Setting();
  bool isloading = false;
  void test() {}
  void register() async {
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
                alertTitle:
                    richTitle(AppLocalizations.of(context).tr("Successed")),
                alertSubtitle: richSubtitle(
                    AppLocalizations.of(context).tr("Click button below")),
                alertType: RichAlertType.SUCCESS,
                actions: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.border_all,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      /*Navigator.pushReplacement(context, MaterialPageRoute(
                                  builder: (context) => ModelLogin(),
                                ));*/
                    },
                  )
                ],
              );
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          AppLocalizations.of(context).tr("Register"),
          textAlign: TextAlign.center,
        )),
      ),
      body: ListView(
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
                    decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context).tr("First name")),
                    validators: [
                      FormBuilderValidators.required(
                          errorText: AppLocalizations.of(context)
                              .tr("Please enter first name")),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                  ),
                  FormBuilderTextField(
                    attribute: "last_name",
                    decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context).tr("Last name")),
                    validators: [
                      FormBuilderValidators.required(
                          errorText: AppLocalizations.of(context)
                              .tr("Please enter last name")),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                  ),
                  FormBuilderTextField(
                    attribute: "email",
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).tr("Email")),
                    validators: [
                      FormBuilderValidators.max(255),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                  ),
                  FormBuilderTextField(
                    attribute: "phone",
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context).tr("Phone number")),
                    validators: [
                      FormBuilderValidators.required(
                          errorText: AppLocalizations.of(context)
                              .tr("Please enter phone number")),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                  ),
                  Divider(),
                  FormBuilderTextField(
                    attribute: "username",
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).tr("Username")),
                    validators: [
                      FormBuilderValidators.required(
                          errorText: AppLocalizations.of(context)
                              .tr("Please enter username")),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                  ),
                  FormBuilderTextField(
                    attribute: "password",
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).tr("Password")),
                    validators: [
                      FormBuilderValidators.required(
                          errorText: AppLocalizations.of(context).tr(
                              "Please enter password")),
                      FormBuilderValidators.min(4,
                          errorText:
                             AppLocalizations.of(context).tr("Password must contain 4 or more digits")),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                  ),
                  FormBuilderTextField(
                    attribute: "password_confirm",
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).tr("Password confirm")),
                    validators: [
                      FormBuilderValidators.required(),
                      (val) {
                        if (_fbKey.currentState.fields['password'].currentState
                                .value !=
                            val) {
                          return AppLocalizations.of(context).tr("Password confirm is incorect");
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
                                  AppLocalizations.of(context).tr("Submit"),
                                  style: TextStyle(color: Colors.white),
                                ),
                                key: null,
                                onPressed: () {
                                  if (_fbKey.currentState.saveAndValidate()) {
                                    register();
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
