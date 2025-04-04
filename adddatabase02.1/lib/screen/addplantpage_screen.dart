import 'package:app/main.dart';
import 'package:app/provider/plant_provider.dart';
import 'package:app/structure/plant.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class AddPlantPage extends StatefulWidget {
  final String category; //แสดงรายการหมวดหมู่ของต้นไม้
  const AddPlantPage({super.key, required this.category});

  @override
  State<AddPlantPage> createState() => _AddPlantPageState();
}

class _AddPlantPageState extends State<AddPlantPage> {
  final TextEditingController _dateController =
      TextEditingController(); //จัดการข้อมูลวันที่
  Color selectedBorderColor = Colors.black;

  @override
  void initState() {
    super.initState();
    selectedBorderColor; // กำหนดสีเริ่มต้น
  }

  InputDecoration buildInputDecoration() {
    return InputDecoration(
      floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  //ทำให้ไม่มีการใช้หน่วยความจำที่ไม่จำเป็นเมื่อstateของหน้าพัง
  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController =
      TextEditingController(); // ชื่อต้นไม้
  final TextEditingController typeController =
      TextEditingController(); // ชนิดต้นไม้
  final TextEditingController dateController = TextEditingController();

  DateTime? selectedDate; // เก็บวันที่ที่เลือก

  // ฟังก์ชันเปิด ColorPicker
  void openColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('เลือกสีกรอบ'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedBorderColor, // สีที่เลือกก่อนหน้า
              onColorChanged: (color) {
                setState(() {
                  selectedBorderColor = color; // เปลี่ยนสีที่เลือก
                });
              },
              pickerAreaHeightPercent: 0.8, // ขนาดของพื้นที่เลือกสี
            ),
          ),

          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('ยืนยัน'),
            ),
          ],
        );
      },
    );
  }

  // วิดเจ็ตสร้างวงกลมสีเพื่อให้เลือก
  Widget _buildColorCircle(Color color, {bool isColorPickerEnabled = false}) {
    return GestureDetector(
      onTap: () {
        if (isColorPickerEnabled) {
          openColorPicker(); // เมื่อแตะวงกลมสีรุ้ง จะเปิด ColorPicker
        } else {
          setState(() {
            selectedBorderColor = color; // กำหนดสีที่เลือกไว้
          });
        }
      },
      child: CircleAvatar(
        backgroundColor: color,
        radius: 16, // ขนาดของวงกลม
      ),
    );
  }

  // วิดเจ็ตสร้างวงกลมที่มีสีรุ้ง
  Widget _buildRainbowColorCircle() {
    return GestureDetector(
      onTap: openColorPicker, // เมื่อแตะจะเปิด ColorPicker
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Colors.red,
              Colors.orange,
              Colors.yellow,
              Colors.green,
              Colors.blue,
              Colors.indigo,
              Colors.purple,
            ], // สีรุ้งในวงกลม
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          "Add your plant",
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),

        //save button
        actions: [
          TextButton(
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                var name = nameController.text;
                var type = typeController.text;

                // สร้าง Plant object
                Plant statement = Plant(
                  name: name,
                  type: type,
                  date:
                      selectedDate ??
                      DateTime.now(), // ใช้วันที่เลือก หรือวันที่ปัจจุบัน
                  color: selectedBorderColor,
                );

                // เรียก provider เพื่อบันทึกข้อมูล
                var provider = Provider.of<PlantProvider>(
                  context,
                  listen: false,
                );
                provider.addPlant(statement);

                //ไปที่หน้าHome
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: selectedBorderColor.withOpacity(0.2),
                  border: Border.all(color: selectedBorderColor, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Image.network(
                      'https://cdn-icons-png.flaticon.com/512/2909/2909769.png',
                      width: 80,
                    ),
                    TextFormField(
                      controller: nameController,
                      decoration: buildInputDecoration().copyWith(
                        labelText: 'Name :',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: typeController,
                      decoration: buildInputDecoration().copyWith(
                        labelText: 'Type :',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: dateController,
                      decoration: buildInputDecoration().copyWith(
                        labelText: 'DD/MM/YY :',
                      ),
                      readOnly: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // วางแถวของวงกลมสีที่ผู้ใช้สามารถเลือก
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // วงกลมที่มีสีรุ้ง ซึ่งจะเปิด ColorPicker เมื่อคลิก
                  _buildRainbowColorCircle(),
                  // วงกลมสีอื่นๆ ที่ไม่เปิด ColorPicker
                  _buildColorCircle(Colors.pink),
                  _buildColorCircle(Colors.green),
                  _buildColorCircle(Colors.yellow),
                  _buildColorCircle(Colors.purple),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: buildInputDecoration().copyWith(
                  labelText: 'ชื่อต้นไม้',
                ),
                autofocus: true,
                controller: nameController,
                validator: (String? str) {
                  if (str == null || str.isEmpty) {
                    return "กรุณากรอกชื่อต้นไม้";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              //Dropdownเลือกชนิดต้นไม้
              DropdownButtonFormField<String>(
                decoration: buildInputDecoration().copyWith(
                  labelText: 'เลือกชนิดต้นไม้',
                ),
                items:
                    widget.category == "TREE"
                        ? ['กะเพรา', 'พลูด่าง', 'กระบองเพชร']
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList()
                        : ['กุหลาบ', 'เดซี่', 'กล้วยไม้']
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                onChanged: (value) {
                  typeController.text = value ?? "";
                },
              ),
              const SizedBox(height: 16),

              //เลือกวันที่ปลูก
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: buildInputDecoration().copyWith(
                  labelText: 'วันที่เริ่มปลูก',
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    // เมื่อผู้ใช้เลือกวันที่
                    dateController.text =
                        '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
                    setState(() {
                      selectedDate = pickedDate; // เก็บวันที่ที่เลือก
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),

      //แถบเมนูข้างล่าง
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.lightGreen,
        selectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_alarm_outlined),
            label: '',
          ),
        ],
      ),
    );
  }
}
