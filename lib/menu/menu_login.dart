import "package:flutter/material.dart";
import 'package:maplaos/model/model_login.dart';

class MenuLogin extends StatefulWidget {
  @override
  _MenuLoginState createState() => _MenuLoginState();
}

class _MenuLoginState extends State<MenuLogin> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: Icon(
            Icons.enhanced_encryption,
            color: Colors.blue,
          ),
          title: Text(
            '​ເຂົ້າ​ລະ​ບົບ',
            style: TextStyle(fontSize: 20.0),
          ),
          subtitle: Text(
            'Login',
            style: TextStyle(fontSize: 12.0),
          ),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>ModelLogin()),
            );
          },
        ),
      ],
    );
  }
}
