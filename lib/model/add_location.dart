import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:latlong/latlong.dart';
import 'package:maplaos/model/alert.dart';
import 'package:maplaos/model/check_location_near.dart';
import 'package:maplaos/setting/setting.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:dio/dio.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart' as location;
import 'package:shared_preferences/shared_preferences.dart';

class AddLocation extends StatefulWidget {
  @override
  _AddLocationState createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocation> {
  CheckLocationNear locationNear = CheckLocationNear();
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  Setting setting = Setting();
  bool isloading = true;
  List listprovinces = List();
  Map provincesMap = Map();
  List listdistricts = List();
  Map districtMap = Map();

  void listProvince() async {
    final conn = await mysql.MySqlConnection.connect(mysql.ConnectionSettings(
        host: setting.host,
        port: setting.port,
        user: setting.user,
        password: setting.password,
        db: setting.db));
    var provinces = await conn.query('select * from provinces');
    for (var province in provinces) {
      if (Localizations.localeOf(context).languageCode == "en") {
        listprovinces.add(province['pro_name']);
        provincesMap[province['pro_name']] = province['id'];
      } else {
        listprovinces.add(province['pro_name_la']);
        provincesMap[province['pro_name_la']] = province['id'];
      }
    }
    setState(() {
      isloading = false;
    });
  }

  void listdistrict(var provincename) async {
    final conn = await mysql.MySqlConnection.connect(mysql.ConnectionSettings(
        host: setting.host,
        port: setting.port,
        user: setting.user,
        password: setting.password,
        db: setting.db));
    var districts = await conn.query(
        'select * from districts where provinces_id=?',
        [provincesMap['$provincename']]);
    for (var district in districts) {
      if (Localizations.localeOf(context).languageCode == "en") {
        listdistricts.add(district['dis_name']);
        districtMap[district['dis_name']] = district['id'];
      } else {
        listdistricts.add(district['dis_name_la']);
        districtMap[district['dis_name_la']] = district['id'];
      }
    }
    setState(() {
      listdistricts = listdistricts;
      districtMap = districtMap;
    });
  }

/* ==================== uplaod photo ================*/
  var _imageBg;
  //var photo_bg;
  bool isloadimgBg = false;
  List listphoto = List();
  Future uploadphoto(var type) async {
    var conn;
    try {
      conn = await mysql.MySqlConnection.connect(mysql.ConnectionSettings(
          host: setting.host,
          port: setting.port,
          user: setting.user,
          password: setting.password,
          db: setting.db,
          timeout: Duration(seconds: 5)));
    } on Exception {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Alert();
          });
    }
    var imageBgFile = (type == 'camera')
        ? await ImagePicker.pickImage(source: ImageSource.camera)
        : await ImagePicker.pickImage(source: ImageSource.gallery);
    if (imageBgFile != null) {
      setState(() {
        _imageBg = imageBgFile;
        isloadimgBg = true;
      });
      /*============ Drop Images =================*/
      File croppedFile = await ImageCropper.cropImage(
          sourcePath: imageBgFile.path,
          ratioX: 1.0,
          ratioY: 1.0,
          toolbarTitle: AppLocalizations.of(context).tr('Crop photo'),
          toolbarColor: Colors.red);
      if (croppedFile != null) {
        imageBgFile = croppedFile;
        /*============ Send Images to API Save =================*/
        Dio dio = new Dio();
        FormData formData = new FormData.from(
            {"filepost": new UploadFileInfo(imageBgFile, "upload1.jpg")});
        try {
          var response = await dio.post("${setting.apiUrl}/uploadfile",
              data: formData, options: Options(method: 'POST'));
          if (response.statusCode == 200) {
            print(response.data);
            setState(() {
              isloadimgBg = false;
              listphoto.add(response.data);
            });
          } else {
            print('Error upload image');
          }
        } on DioError catch (e) {
          print('Errors upload bg');
        }
      } else {
        setState(() {
          isloadimgBg = false;
        });
      }
    }
  }

  double latitudecurrent;
  double longtitudecurrent;
  bool isgetcurrent = true;
  void getcurrentlocation() async {
    setState(() {
      isgetcurrent = false;
    });
    location.LocationData currentLocation =
        await location.Location().getLocation();
    setState(() {
      longtitudecurrent = currentLocation.longitude;
      latitudecurrent = currentLocation.latitude;
      isgetcurrent = true;
    });
  }

  bool isloadingsave = false;
  void savelocation() async {
    setState(() {
      isloadingsave = true;
    });
    Dio dio = new Dio();
    var response = await dio.get("${setting.apiUrl}/textsearch"); // for update text search

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getInt('userId');
    bool cansave = true;
    var status = "Pedding";
    if (prefs.getString('userType') == "admin") {
      status = 'Open';
    }
    final conn = await mysql.MySqlConnection.connect(mysql.ConnectionSettings(
        host: setting.host,
        port: setting.port,
        user: setting.user,
        password: setting.password,
        db: setting.db));
    var data = _fbKey.currentState.value;
    var locations = await conn.query(
        'select latitude, longitude from location where latitude !=?', [0]);
    for (var location in locations) {
      final Distance distance = new Distance();
      // meter = 422591.551
      final double meter = distance(
          new LatLng(double.parse(data['latitude'].toString()),
              double.parse(data['longtitude'].toString())),
          new LatLng(double.parse(location['latitude'].toString()),
              double.parse(location['longitude'].toString())));
      if (meter < 500) {
        cansave = false;
        setState(() {
          isloadingsave = false;
        });
        showModalBottomSheet<void>(
          context: context,
          builder: (BuildContext context) {
            return Container(
              height: 80.0,
              child: ListTile(
                leading: Icon(
                  Icons.error_outline,
                  color: Colors.red,
                ),
                title: Text(
                  AppLocalizations.of(context)
                      .tr("This location has already exist!"),
                  style: TextStyle(fontSize: 16.0, color: Colors.red),
                ),
              ),
            );
          },
        );
        break;
      }
    }
    if (cansave) {
      var saveloca = await conn.query(
          'insert into location (latitude, longitude, loc_name,loc_name_la,type_location_id,provinces_id,districts_id,villages_id,user_id,status) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            data['latitude'],
            data['longtitude'],
            data['loc_name'],
            data['loc_name_la'],
            null,
            provincesMap[data['province_name']],
            districtMap[data['district_name']],
            null,
            user_id,
            status
          ]);
      if (saveloca.insertId != null) {
        for (var photo in listphoto) {
          var savephoto = await conn.query(
              'insert into photo (photo, location_id) values (?, ?)',
              [photo, saveloca.insertId]);
        }
        var savedetail = await conn.query(
            'insert into location_details (details, details_la,location_id) values (?, ?, ?)',
            [data['detail_en'], data['detail_la'], saveloca.insertId]);
      }
    }
    setState(() {
      isloadingsave = false;
    });
  }

  void removephoto(var photo) {
    setState(() {
      listphoto.remove(photo);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listProvince();

    //locationNear.checknear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          AppLocalizations.of(context).tr("Add location tour"),
          textAlign: TextAlign.center,
        )),
      ),
      body: isloading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FormBuilder(
                      key: _fbKey,
                      autovalidate: true,
                      child: Column(
                        children: <Widget>[
                          FormBuilderDropdown(
                            attribute: "province_name",
                            decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)
                                    .tr('Province')),
                            // initialValue: 'Male',
                            hint: Text(AppLocalizations.of(context)
                                .tr('=== Select Province ===')),
                            validators: [FormBuilderValidators.required()],
                            items: listprovinces
                                .map((province) => DropdownMenuItem(
                                    value: province, child: Text("$province")))
                                .toList(),
                            onChanged: (value) {
                              listdistrict(value);
                              //print(value);
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.all(10),
                          ),
                          FormBuilderDropdown(
                            attribute: "district_name",
                            decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)
                                    .tr('District')),
                            // initialValue: 'Male',
                            hint: Text(AppLocalizations.of(context)
                                .tr('=== Select district ===')),
                            validators: [FormBuilderValidators.required()],
                            items: listdistricts
                                .map((district) => DropdownMenuItem(
                                    value: district, child: Text("$district")))
                                .toList(),
                            onChanged: (value) {
                              //listdistrict(value);
                              //print(value);
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.all(10),
                          ),
                          FormBuilderTextField(
                            attribute: "loc_name_la",
                            decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)
                                    .tr('Localition name lao')),
                            validators: [
                              FormBuilderValidators.required(),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.all(10),
                          ),
                          FormBuilderTextField(
                            attribute: "loc_name",
                            decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)
                                    .tr('Localition name english')),
                            validators: [
                              FormBuilderValidators.required(),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.all(10),
                          ),
                          isgetcurrent
                              ? Column(
                                  children: <Widget>[
                                    FormBuilderTextField(
                                      attribute: "latitude",
                                      decoration: InputDecoration(
                                          labelText:
                                              AppLocalizations.of(context)
                                                  .tr('Latitude')),
                                      initialValue: latitudecurrent != null
                                          ? '$latitudecurrent'
                                          : '',
                                      validators: [
                                        FormBuilderValidators.required(),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                    ),
                                    FormBuilderTextField(
                                      attribute: "longtitude",
                                      initialValue: longtitudecurrent != null
                                          ? '$longtitudecurrent'
                                          : '',
                                      decoration: InputDecoration(
                                          labelText:
                                              AppLocalizations.of(context)
                                                  .tr('Longtitude')),
                                      validators: [
                                        FormBuilderValidators.required(),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(2),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: InkWell(
                                          child: new Text(
                                              AppLocalizations.of(context).tr(
                                                  'Click get current location')),
                                          onTap: () {
                                            getcurrentlocation();
                                          }),
                                    ),
                                  ],
                                )
                              : SizedBox(
                                  height: 140,
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                ),
                          Padding(
                            padding: EdgeInsets.all(10),
                          ),
                          FormBuilderTextField(
                            attribute: "detail_la",
                            maxLines: 3,
                            decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)
                                    .tr('Details Lao')),
                          ),
                          Padding(
                            padding: EdgeInsets.all(10),
                          ),
                          FormBuilderTextField(
                            attribute: "detail_en",
                            maxLines: 3,
                            decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)
                                    .tr('Details English')),
                          ),
                          Padding(
                            padding: EdgeInsets.all(10),
                          ),
                          Row(
                            children: <Widget>[
                              for (var item in listphoto)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onLongPress: () {
                                        removephoto(item);
                                      },
                                      child: Image.network(
                                          '${setting.apiUrl}/showimg/$item'),
                                    ),
                                  ),
                                )
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.all(10),
                          ),
                          Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: isloadingsave
                                      ? Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : FloatingActionButton(
                                          onPressed: () {
                                            if (_fbKey.currentState
                                                .saveAndValidate()) {
                                              savelocation();
                                            }
                                          },
                                          child: new Icon(
                                            Icons.save,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
              ],
            ),
      floatingActionButton: listphoto.length < 4
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                    context: context,
                    child: AlertDialog(
                        content: Container(
                      height: 80.0,
                      child: Column(
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context).tr('Upload Photo'),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: <Widget>[
                              OutlineButton.icon(
                                label: Text(
                                    AppLocalizations.of(context).tr('GALLERY'),
                                    style: TextStyle(
                                        fontSize: 10.0, color: Colors.black)),
                                icon: Icon(
                                  Icons.image,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  uploadphoto('gallery');
                                  listphoto.length == 3
                                      ? Navigator.of(context).pop()
                                      : print('OK');
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 10.0),
                                child: OutlineButton.icon(
                                  label: Text(
                                      AppLocalizations.of(context).tr('CAMERA'),
                                      style: TextStyle(fontSize: 10.0)),
                                  icon: Icon(
                                    Icons.camera,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    uploadphoto('camera');
                                    listphoto.length == 3
                                        ? Navigator.of(context).pop()
                                        : print('OK');
                                  },
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    )));
              },
              child: Icon(Icons.image),
              backgroundColor: Colors.blue,
            )
          : Text(""),
    );
  }
}
