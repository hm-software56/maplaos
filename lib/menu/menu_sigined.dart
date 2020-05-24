import 'package:flutter/material.dart';
import 'package:maplaos/model/add_location.dart';
import 'package:maplaos/model/model_listlocation.dart';
import 'package:maplaos/model/model_profile.dart';
import 'package:easy_localization/easy_localization.dart';

class MenuSigined extends StatefulWidget {
  @override
  _MenuSiginedState createState() => _MenuSiginedState();
}

class _MenuSiginedState extends State<MenuSigined> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
            leading: Icon(
              Icons.store,
              color: Colors.red,
            ),
            title: Text("Add Location",
              style: TextStyle(fontSize: 16.0),
            ).tr(),
            subtitle: Text(("Manage location").tr(),
              style: TextStyle(fontSize: 12.0),
            ),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Navigator.of(context).pop();
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ModelListLocation(),
                ));
            },
          ),
          ListTile(
            leading: Icon(
              Icons.account_circle,
              color: Colors.red,
            ),
            title: Text(("Profile").tr(),
              style: TextStyle(fontSize: 16.0),
            ),
            subtitle: Text(("Manage Profile").tr(),
              style: TextStyle(fontSize: 12.0),
            ),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
               Navigator.of(context).pop();
            Navigator.push(
                context,
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => ModelProfile(),
                ));
            },
          ),
      ],
    );
  }
}