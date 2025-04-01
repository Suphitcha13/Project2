class Transaction {
  String name; // ชื่อต้นไม้
  String type; // ชนิดต้นไม้
  DateTime date; // วันที่เริ่มปลูก

  static DateTime? selectedDate; // static เพื่อเก็บวันที่ที่เลือก

  // Constructor
  Transaction({required this.name, required this.type, DateTime? date})
    : date = date ?? selectedDate ?? DateTime.now();

  void add(
    Transaction transaction,
  ) {} // ใช้ selectedDate ถ้ามี หรือ วันที่ปัจจุบันถ้าไม่มี
}
