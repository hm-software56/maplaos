import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class HowUs extends StatefulWidget {
  @override
  _HowUsState createState() => _HowUsState();
}

class _HowUsState extends State<HowUs> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          title: Text(('How to use').tr()),
        ),
        body: Container(
          child: Center(
            child: Text(Localizations.localeOf(context).languageCode),
          ),
        ),
    );
  }
}
