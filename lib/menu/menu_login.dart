import "package:flutter/material.dart";
import 'package:maplaos/model/model_login.dart';
import 'package:easy_localization/easy_localization.dart';
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
            color: Colors.red,
          ),
          title: Text(AppLocalizations.of(context).tr("Login"),
            style: TextStyle(fontSize: 20.0),
          ),
          subtitle: Text(
            'Login',
            style: TextStyle(fontSize: 12.0),
          ),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.push(
                context,
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => ModelLogin(),
                ));
          },
        ),
      ],
    );
  }
}
