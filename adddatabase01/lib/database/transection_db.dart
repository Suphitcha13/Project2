import 'dart:io';
import 'package:app/structure/transections.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

class TransactionDB {
  String dbName;

  TransactionDB({required this.dbName});

  // เปิดฐานข้อมูล
  Future<Database> openDatabase() async {
    // หาตำแหน่งที่จะเก็บฐานข้อมูล
    Directory appDirectory = await getApplicationDocumentsDirectory();
    String dbLocation = join(appDirectory.path, dbName);

    // เปิดฐานข้อมูล NoSQL ด้วย Sembast
    var database = await databaseFactoryIo.openDatabase(dbLocation);

    return database;
  }

  // บันทึกข้อมูลในรูปแบบ JSON
  Future<int> InsertData(Transactions statement) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store("expense");

    // สร้างข้อมูลที่ต้องการบันทึกในรูปแบบ JSON
    var keyID = await store.add(db, {
      'name': statement.name,
      'type': statement.type,
      'date': statement.date.toIso8601String(),
    });
    db.close();
    return keyID;
  }

  // ดึงข้อมูล ใหม่ => เก่า (false)
  Future<List<Transactions>> loadAllData() async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store("expense");
    var snapshot = await store.find(
      db,
      finder: Finder(sortOrders: [SortOrder(Field.key, false)]),
    );

    List<Transactions> transectionList = [];

    for (var record in snapshot) {
      String name = record["name"]?.toString() ?? "";
      String type = record["type"]?.toString() ?? "";
      DateTime date = DateTime.now();

      var dateValue = record["date"];
      if (dateValue != null && dateValue is String) {
        try {
          date = DateTime.parse(dateValue);
        } catch (e) {
          date = DateTime.now();
        }
      }

      transectionList.add(Transactions(name: name, type: type, date: date));
    }
    return transectionList;
  }
}
