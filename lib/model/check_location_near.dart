
import 'package:latlong/latlong.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:maplaos/setting/setting.dart';
class CheckLocationNear{

 checknear()async
{
  Setting setting = Setting();
  final conn = await mysql.MySqlConnection.connect(mysql.ConnectionSettings(
        host: setting.host,
        port: setting.port,
        user: setting.user,
        password: setting.password,
        db: setting.db));
  
    var locations = await conn.query('select latitude, longitude from location');
    for (var location in locations) {
      
    }
  final Distance distance = new Distance();
    
    // km = 423
    final double km = distance.as(LengthUnit.Kilometer,
     new LatLng(52.518611,13.408056),new LatLng(51.519475,7.46694444));
    
    // meter = 422591.551
    final double meter = distance(
        new LatLng(52.518611,13.408056),
        new LatLng(51.519475,7.46694444)
        );
    //print(km);
    print(meter);
    //return meter;
  await conn.close();
}
}