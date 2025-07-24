import 'dart:io';
import 'dart:ui';
import 'package:app/structure/plant.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart' as sembast;
import 'package:sembast/sembast_io.dart';

//Sambast-NoSQL(ไม่ใช้Server)
class PlantDB {
  String dbName; //ระบุชื่อไฟล์

  PlantDB({required this.dbName});

  // เปิดฐานข้อมูล
  Future<sembast.Database> openDatabase() async {
    Directory appDirectory =
        await getApplicationDocumentsDirectory(); //ใช้ค้นหาโฟล์เดอร์ที่เหมาะสมในมือถือ
    String dbLocation = join(appDirectory.path, dbName); //รวมpathกับชื่อไฟล์
    var database = await databaseFactoryIo.openDatabase(dbLocation);
    return database;
  }

  // บันทึกข้อมูลในรูปแบบ JSON
  Future<int> insertData(Plant statement) async {
    var db = await openDatabase(); //เปิดฐานข้อมูล
    var store = intMapStoreFactory.store("plants");

    // แปลงค่า color เป็น int
    var keyID = await store.add(db, {
      'name': statement.name,
      'type': statement.type,
      'color': statement.color.value, // แปลงสีเป็น int
      'date': statement.date.toIso8601String(),
    });

    db.close();
    return keyID;
  }

  // ลบข้อมูลจากฐานข้อมูล
  Future<void> deleteData(Plant statement) async {
    var db = await openDatabase(); //เปิดฐานข้อมูล
    var store = intMapStoreFactory.store("plants"); //ค้นหาstoreชื่อexpense
    await store.delete(
      db,
      finder: Finder(
        filter: Filter.equals('name', statement.name),
      ), //ค้นหาข้อมูลที่nameตรงกัน
    );
    db.close();
  }

  // ฟังก์ชันโหลดข้อมูล
  Future<List<Plant>> loadAllData() async {
    var db = await openDatabase(); //เปิดฐานข้อมูลชื่อplant.db
    var store = intMapStoreFactory.store("plants"); //อ่านข้อมูลจากstore
    var snapshot = await store.find(
      db,
      finder: Finder(
        sortOrders: [SortOrder(Field.key, false)],
      ), //ดึงข้อมูลทั้งหมดและเรียงลำดับ
    );

    List<Plant> plantList = [];
    for (var record in snapshot) {
      String name = record["name"]?.toString() ?? "";
      String type = record["type"]?.toString() ?? "";
      DateTime date = DateTime.now();

      // แปลงค่า color จาก Object? เป็น int
      final Color color = Color(record["color"] as int);

      var dateValue = record["date"];
      if (dateValue != null && dateValue is String) {
        try {
          date = DateTime.parse(dateValue);
        } catch (e) {
          date = DateTime.now();
        }
      }

      plantList.add(Plant(name: name, type: type, date: date, color: color));
    }
    return plantList;
  }
}
