import 'package:app/structure/transections.dart';
import 'package:flutter/foundation.dart';
import 'package:app/database/transection_db.dart';

class TransactionProvider with ChangeNotifier {
  List<Transactions> transactions = [];

  // ดึงข้อมูล
  List<Transactions> getTransaction() {
    return transactions;
  }

  // ฟังก์ชันแสดงข้อมูลตอนเริ่มต้น
  void initData() async {
    var db = TransactionDB(dbName: "Transection.db");
    transactions = await db.loadAllData(); // โหลดข้อมูลจากฐานข้อมูล
    notifyListeners(); // แจ้งให้ UI รีเฟรช
  }

  // ฟังก์ชันเพิ่มข้อมูล
  void addTransection(Transactions statement) async {
    var db = TransactionDB(dbName: "Transection.db");
    await db.insertData(statement); // บันทึกข้อมูล
    transactions = await db.loadAllData(); // โหลดข้อมูลใหม่จากฐานข้อมูล
    notifyListeners(); // แจ้งให้ UI รีเฟรช
  }

  // ฟังก์ชันลบข้อมูล
  void deleteTransaction(int index) async {
    var db = TransactionDB(dbName: "Transection.db");
    await db.deleteData(transactions[index]); // ลบข้อมูลจากฐานข้อมูล
    transactions.removeAt(index); // ลบข้อมูลจาก list ใน memory
    notifyListeners(); // แจ้งให้ UI รีเฟรช
  }
}
