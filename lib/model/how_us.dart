import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class HowUs extends StatefulWidget {
  @override
  _HowUsState createState() => _HowUsState();
}

class _HowUsState extends State<HowUs> {
  @override
  Widget build(BuildContext context) {
    var data = EasyLocalizationProvider.of(context).data;
    return EasyLocalizationProvider(
      data: data,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).tr('How to use')),
        ),
        body: Container(
          child: Center(
            child: Text(Localizations.localeOf(context).languageCode),
          ),
        ),
      ),
    );
  }
}
