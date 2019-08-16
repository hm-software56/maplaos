import "package:flutter/material.dart";
import 'package:mysql1/mysql1.dart';

class Setting {
  var apiUrl = "http://192.168.100.13:8080/index.php?r=";
  var urlimg = "http://192.168.100.165:8080/images";
  //var host = 'remotemysql.com';
  //var host = '192.168.43.55';
  //var host = '10.11.14.122';
  var host = '192.168.100.165';
  int port = 3306;
  //// var user = '2CEvh1t8JM';
  //var password = '5N1nJoJJTN';
  //var db = '2CEvh1t8JM';
  var user = 'daxiong';
  var password = 'Da123!@#';
  var db = 'maplaos_db';
  double latitude = 17.974855;
  double longitude = 102.609986;
  double zoom = 5;
}
