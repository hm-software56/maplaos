import 'package:mysql1/mysql1.dart';
import 'dart:async';

class Db {
     final dd= MySqlConnection.connect(new ConnectionSettings(
        host: 'remotemysql.com',
        port: 3306,
        user: '2CEvh1t8JM',
        password: '5N1nJoJJTN',
        db: '2CEvh1t8JM'));
}
