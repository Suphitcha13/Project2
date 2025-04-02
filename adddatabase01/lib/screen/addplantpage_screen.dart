import 'package:app/main.dart';
import 'package:app/provider/transection_provider.dart';
import 'package:app/structure/transections.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddPlantPage extends StatefulWidget {
  final String category;
  const AddPlantPage({Key? key, required this.category}) : super(key: key);

  @override
  State<AddPlantPage> createState() => _AddPlantPageState();
}

class _AddPlantPageState extends State<AddPlantPage> {
  final TextEditingController _dateController = TextEditingController();

  Color selectedBorderColor = Colors.black;

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

                // สร้าง Transaction object
                Transactions statement = Transactions(
                  name: name,
                  type: type,
                  date:
                      selectedDate ??
                      DateTime.now(), // ใช้วันที่เลือก หรือวันที่ปัจจุบัน
                );

                // เรียก provider เพื่อบันทึกข้อมูล
                var provider = Provider.of<TransactionProvider>(
                  context,
                  listen: false,
                );
                provider.addTransection(statement);

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
        centerTitle: true,
        title: const Text(
          "Add your plant",
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildColorCircle(Colors.black),
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

  Widget _buildColorCircle(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedBorderColor = color;
        });
      },
      child: CircleAvatar(backgroundColor: color, radius: 16),
    );
  }
}
