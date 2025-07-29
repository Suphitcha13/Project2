import 'package:flutter/material.dart';

class Plant {
  final String name;
  final String type;
  final DateTime date;
  final Color color;
  final String? sensorAddress; // เพิ่มฟิลด์ sensorAddress

  Plant({
    required this.name,
    required this.type,
    required this.date,
    required this.color,
    this.sensorAddress, // เพิ่มในคอนสตรัคเตอร์
  });

  // ถ้าใช้ JSON serialization ให้เพิ่มฟังก์ชันเหล่านี้
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'date': date.toIso8601String(),
      'color': color.value,
      'sensorAddress': sensorAddress, // เพิ่มในการแปลงเป็น JSON
    };
  }

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      name: json['name'],
      type: json['type'],
      date: DateTime.parse(json['date']),
      color: Color(json['color']),
      sensorAddress: json['sensorAddress'], // เพิ่มในการแปลงจาก JSON
    );
  }

  // Copy with method สำหรับการอัปเดตข้อมูล
  Plant copyWith({
    String? name,
    String? type,
    DateTime? date,
    Color? color,
    String? sensorAddress,
  }) {
    return Plant(
      name: name ?? this.name,
      type: type ?? this.type,
      date: date ?? this.date,
      color: color ?? this.color,
      sensorAddress: sensorAddress ?? this.sensorAddress,
    );
  }

  @override
  String toString() {
    return 'Plant(name: $name, type: $type, date: $date, color: $color, sensorAddress: $sensorAddress)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Plant &&
        other.name == name &&
        other.type == type &&
        other.date == date &&
        other.color == color &&
        other.sensorAddress == sensorAddress;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        type.hashCode ^
        date.hashCode ^
        color.hashCode ^
        sensorAddress.hashCode;
  }
}
