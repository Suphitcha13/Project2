import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // ✅ import ให้เรียกใช้ฟอนต์
import 'package:app/structure/plant.dart';
import 'package:app/main.dart';
import 'package:app/screen/sugges_screen.dart'; // หรือ path ที่ `HomePage` อยู่

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // ประกาศตัวแปร selectedBorderColor
  Color selectedBorderColor = Colors.black;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.maliTextTheme(), // << เปลี่ยนฟอนต์ทั้งแอป
      ),
      home: PlantPage(
        plant: Plant(
          name: 'name',
          type: 'type',
          date: DateTime.now(),
          color: selectedBorderColor,
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PlantPage extends StatefulWidget {
  final Plant plant;

  const PlantPage({Key? key, required this.plant}) : super(key: key);

  @override
  _PlantPageState createState() => _PlantPageState();
}

class _PlantPageState extends State<PlantPage> {
  double temperature = 30.0;
  int humidity = 53;
  int soilMoisture = 40; // ตัวอย่างค่าที่มาจาก sensor

  @override
  void initState() {
    super.initState();
    // mock อัปเดตจาก Arduino
    // ตัวอย่างการอ่านค่าจริง ให้ใช้ Bluetooth/Serial แล้ว setState เหมือนด้านล่าง
    // setState(() {
    //   temperature = newTemp;
    //   humidity = newHumidity; soilMoisture = newSoil;
    // });
  }

  String getSoilMoistureImage(int moisture) {
    if (moisture <= 0) {
      return 'assets/0.PNG'; // รูปตอนแห้งมาก
    } else if (moisture > 0 && moisture <= 25) {
      return 'assets/25.PNG'; // รูปชื้นนิด ๆ
    } else if (moisture > 25 && moisture <= 50) {
      return 'assets/50.PNG';
    } else if (moisture > 50 && moisture <= 75) {
      return 'assets/75.PNG';
    } else {
      return 'assets/100.PNG'; // รูปชุ่มมาก
    }
  }

  String getTreeImage(String type) {
    switch (type) {
      case 'เดซี่':
        return 'assets/daisy.png';
      case 'กุหลาบ':
        return 'assets/rose.PNG';
      case 'กล้วยไม้':
        return 'assets/ochid.png';
      case 'กะเพรา':
        return 'assets/basil.png';
      case 'พลูด่าง':
        return 'assets/pothos.png';
      case 'กระบองเพชร':
        return 'assets/cac.png';
      default:
        return 'assets/tree.png'; // รูป default
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFFA7E584),
        onTap: (index) {
          if (index == 0) {
            // ✅ กลับไปหน้า HomePage
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
              (route) => false,
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SuggestPage(transaction: widget.plant),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: ''),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Color(0xFFA7E584),
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.plant.name,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context); // ✅ กลับหน้าก่อนหน้า
                  },
                  icon: Icon(Icons.arrow_back),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFFA7E584),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text("Day 1", style: TextStyle(fontSize: 16)),
                ),
              ],
            ),

            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(width: 2),
                borderRadius: BorderRadius.circular(12),
                color: widget.plant.color,
              ),
              child: Column(
                children: [
                  Image.asset(getTreeImage(widget.plant.type), height: 150),

                  const SizedBox(height: 10),
                  buildInfoRow("Name :", widget.plant.name),
                  buildInfoRow("ชนิด :", widget.plant.type),
                  buildInfoRow(
                    "DD/MM/YY :",
                    "${widget.plant.date.day}/${widget.plant.date.month}/${widget.plant.date.year}",
                  ),
                ],
              ),
            ),
            // Icon(Icons.local_drink, size: 60),
            // const SizedBox(height: 10),
            Column(
              children: [
                Image.asset(getSoilMoistureImage(soilMoisture), height: 100),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Temperature", style: TextStyle(fontSize: 16)),
                        Text("Humidity", style: TextStyle(fontSize: 16)),
                        Text("Soil Moisture", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${temperature.toStringAsFixed(1)} °C",
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          "$humidity%",
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          "$soilMoisture%",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(width: 8),
        Expanded(child: Text(value)),
      ],
    );
  }
}
