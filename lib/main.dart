import 'package:flutter/material.dart';
import 'package:maplaos/home.dart';
import 'package:maplaos/homescreen.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';

import 'model/how_us.dart';
import 'model/add_location.dart';
void main() => runApp(EasyLocalization(child: MyApp()));

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var data = EasyLocalizationProvider.of(context).data;
    return EasyLocalizationProvider(
      data: data,
      child: MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          //app-specific localization
          EasylocaLizationDelegate(
              locale: data.locale,
              path: 'resources/langs'),
        ],
        supportedLocales: [Locale('en', 'US'), Locale('lo', 'LA')],
        locale: data.savedLocale,

        debugShowCheckedModeBanner: false,
        title: 'Maplaos',
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        routes: <String, WidgetBuilder>{
          '/home': (BuildContext context) => Home()
        },
        home: HomeScreen(),
      ),
    );
  }
}
