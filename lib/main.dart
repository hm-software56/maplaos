import 'package:flutter/material.dart';
import 'package:maplaos/home.dart';
import 'package:maplaos/homescreen.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';

void main() => runApp(EasyLocalization(
      supportedLocales: [Locale('lo', 'LA'), Locale('en', 'US')],
      path: 'resources/langs', // <-- change patch to your
      fallbackLocale: Locale('lo', 'LA'),
      child: MyApp()
    ),
);

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //context.locale = Locale('lo', 'LA'); //selected lenguage
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
        title: 'Maplaos',
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
      home: HomeScreen()
    );
  }
}
