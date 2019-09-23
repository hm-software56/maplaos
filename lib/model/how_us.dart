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
          //title: Text('ວິ​ທີ​ນຳ​ໃຊ້​/How to use'),
          actions: <Widget>[
            FlatButton(
              child: Text("English"),
              color: Localizations.localeOf(context).languageCode == "en"
                  ? Colors.lightBlueAccent
                  : Colors.blue,
              onPressed: () {
                this.setState(() {
                  data.changeLocale(Locale("en", "US"));
                  print(Localizations.localeOf(context).languageCode);
                });
              },
            ),
            FlatButton(
              child: Text("Lao"),
              color: Localizations.localeOf(context).languageCode == "ar"
                  ? Colors.lightBlueAccent
                  : Colors.blue,
              onPressed: () {
                this.setState(() {
                  data.changeLocale(Locale("lo", "LA"));
                  print(Localizations.localeOf(context).languageCode);
                });
              },
            )
          ],
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
