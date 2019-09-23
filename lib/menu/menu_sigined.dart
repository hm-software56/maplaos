import 'package:flutter/material.dart';
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
            title: Text(AppLocalizations.of(context).tr("Add Location"),
              style: TextStyle(fontSize: 20.0),
            ),
            subtitle: Text(
              'Add location',
              style: TextStyle(fontSize: 12.0),
            ),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Navigator.of(context).pushNamed('/listhouseuser');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.account_circle,
              color: Colors.red,
            ),
            title: Text(AppLocalizations.of(context).tr("Profile"),
              style: TextStyle(fontSize: 20.0),
            ),
            subtitle: Text(AppLocalizations.of(context).tr("Manage Profile"),
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