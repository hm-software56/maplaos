import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:maplaos/setting/setting.dart';

class AboutUs extends StatefulWidget {
  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  Setting setting = Setting();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).tr('About Us')),
      ),
      body: Container(
        padding: EdgeInsets.all(5.0),
        child: Center(
          child: ListView(
            children: <Widget>[
              Text(
                  'ສຶກສາຄົ້ນຄ້ວາອອກແບບ ແລະ ພັດທະນາລະບົບນີ້ຈາກນັກສືກສາປະລິນຍາໂທ, ສາຂາ ວິທະຍາສາດທຳມະຊາດ, ພາກວິຊາ ວິທະຍາສາດຄອມພິວເຕີ, ລຸ້ນທີ່ 1'),
              Divider(),
              ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      NetworkImage('${setting.apiUrl}/showimg/daxiong.jpg'),
                ),
                title: Text(
                  'ຊື່ຜູ້ຄົ້ນຄວ້າ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('ທ. ດາຊົ່ງ ໂຊ້ງຢັງເຊັ່ງ'),
                trailing: Icon(Icons.more_vert),
                isThreeLine: true,
              ),
              Divider(),
              ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      NetworkImage('${setting.apiUrl}/showimg/sumsack.jpg'),
                ),
                title: Text(
                  'ອາຈານທີ່ປືກສາ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('ປອ ສົມສັກ ອິນທະສອນ'),
                trailing: Icon(Icons.more_vert),
                isThreeLine: true,
              ),
              Divider(),
              ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      NetworkImage('${setting.apiUrl}/showimg/latsami.jpg'),
                ),
                title: Text(
                  'ອາຈານທີ່ປືກສາ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('ປອ ລັດສະໝີ ຈິດຕະວົງ'),
                trailing: Icon(Icons.more_vert),
                isThreeLine: true,
              ),
              Divider(),
              Center(
                  child: Text(
                'ສະໜັບສະໜູນໂດຍ',
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          width: 190.0,
                          height: 130.0,
                          decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                  fit: BoxFit.fill,
                                  image: new NetworkImage(
                                      '${setting.apiUrl}/showimg/cbr.jpg')))),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          width: 190.0,
                          height: 130.0,
                          decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                  fit: BoxFit.fill,
                                  image: new NetworkImage(
                                      '${setting.apiUrl}/showimg/trl.jpg')))),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
