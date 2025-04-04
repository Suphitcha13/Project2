//ใช้จัดเก็บข้อมูลต้นไม้แต่ละต้น

import 'dart:ui';

class Plant {
  String name; // ชื่อต้นไม้
  String type; // ชนิดต้นไม้
  DateTime date; // วันที่เริ่มปลูก
  final Color color; //สีที่เลือก

  static DateTime? selectedDate; // static เพื่อเก็บวันที่ที่เลือกไว้

  // Constructor
  Plant({
    required this.name,
    required this.type,
    required this.color,
    DateTime? date,
  }) : date = date ?? selectedDate ?? DateTime.now();

  //requiredเพื่อให้ระบุค่า
  //dateส่งnullมาได้
  //ถ้าdateเป็นnullจะใช้ค่าในselectแต่ถ้ายังเป็นnullจะใช้ค่าวันที่ปัจจุบัน
}
