import 'package:app/structure/plant.dart';
import 'package:flutter/foundation.dart';
import 'package:app/database/plant_db.dart';

//สำหรับจัดการข้อมูลต้นไม้
class PlantProvider with ChangeNotifier {
  List<Plant> plant = [];

  // ดึงข้อมูล
  List<Plant> getTransaction() {
    return plant;
  }

  // ฟังก์ชันแสดงข้อมูลตอนเริ่มต้น
  void initData() async {
    var db = PlantDB(dbName: "Plant.db");
    plant = await db.loadAllData(); // โหลดข้อมูลจากฐานข้อมูล
    notifyListeners(); // แจ้งให้ UI รีเฟรช
  }

  // ฟังก์ชันเพิ่มข้อมูล
  void addPlant(Plant statement) async {
    var db = PlantDB(dbName: "Plant.db");
    await db.insertData(statement); // บันทึกข้อมูล
    plant = await db.loadAllData(); // โหลดข้อมูลใหม่จากฐานข้อมูล
    notifyListeners(); // แจ้งให้ UI รีเฟรช
  }

  // ฟังก์ชันลบข้อมูล
  void deletePlant(int index) async {
    var db = PlantDB(dbName: "Plant.db");
    await db.deleteData(plant[index]); // ลบข้อมูลจากฐานข้อมูล
    plant.removeAt(index); // ลบข้อมูลจาก list ใน memory
    notifyListeners(); // แจ้งให้ UI รีเฟรช
  }
}
