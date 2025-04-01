import 'package:app/structure/transection.dart';
import 'package:flutter/foundation.dart';

class TransectionProvider with ChangeNotifier {
  // ตัวอย่างข้อมูล
  List<Transaction> transections = [];

  //ดึงข้อมูล
  List<Transaction> getTransaction() {
    return transections;
  }

  // ฟังก์ชันเพิ่มข้อมูล
  void addTransection(Transaction statement) {
    transections.insert(0, statement);
    //แจ้งเตือน consumer
    notifyListeners();
  }
}
