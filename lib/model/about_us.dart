import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
class AboutUs extends StatefulWidget {
  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).tr('About Us')),
      ),
      body: Container(
        child:Center(
          child: Text('Comming soon'),
        ),
      ),
    );
  }
}