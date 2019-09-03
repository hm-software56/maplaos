import 'package:flutter/material.dart';
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
              color: Colors.blue,
            ),
            title: Text(
              '​ເອົາ​ສະ​ຖານ​ທີ່​ເຂົ້າ',
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
              color: Colors.blue,
            ),
            title: Text(
              'ໂປ​ຣ​ໄຟ',
              style: TextStyle(fontSize: 20.0),
            ),
            subtitle: Text(
              'ຈັດ​ການໂປ​ຣ​ໄຟຂອງ​ຕົ້ນ​ເອງ',
              style: TextStyle(fontSize: 12.0),
            ),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Navigator.of(context).pushNamed('/profile');
            },
          ),
      ],
    );
  }
}