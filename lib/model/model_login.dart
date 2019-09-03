import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class ModelLogin extends StatefulWidget {
  @override
  _ModelLoginState createState() => _ModelLoginState();
}

class _ModelLoginState extends State<ModelLogin> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ເຂົ້າ​ລະ​ບົບ'),
      ),
      body: SingleChildScrollView(
        child: Container(
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
                            InputDecoration(labelText: "ຊື່ຜູ້ໃຊ້/Username"),
                        validators: [
                          FormBuilderValidators.max(70),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.all(20),
                      ),
                      FormBuilderTextField(
                        attribute: "password",
                        obscureText: true,
                        decoration:
                            InputDecoration(labelText: "ລະ​ຫັດ​ຜ່ານ/Password"),
                        validators: [
                          FormBuilderValidators.max(70),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton.icon(
                        icon: Icon(
                          Icons.lock_open,
                          color: Colors.white,
                        ),
                        label: Text(
                          'ເຂົ້າ​ລະ​ບົບ/Login',
                          style: TextStyle(color: Colors.white),
                        ),
                        key: null,
                        onPressed: () {
                          if (_fbKey.currentState.saveAndValidate()) {
                            print(_fbKey.currentState.value);
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
                      child: FlatButton(
                        child: Text(
                          '​ລົງ​ທະ​ບຽນ',
                          style: TextStyle(color: Colors.black54),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed('/register');
                        },
                      ),
                    ),
                    Expanded(
                      child: FlatButton(
                        child: Text(
                          'ລືມ​ລະ​ຫັດ​ຜ່ານ​',
                          style: TextStyle(color: Colors.black54),
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            )),
      ),
    );
  }
}
