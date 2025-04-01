import 'package:app/provider/transection_provider.dart';
import 'package:app/structure/transection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            return TransectionProvider();
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', 'US')],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void navigateToAddPlant(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPlantPage()),
    );
  }

  void showCategoryPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.brown[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "SELECT CATEGORIES",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => navigateToAddPlant(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/tree.png', width: 30),
                    const SizedBox(width: 10),
                    const Text(
                      "TREE",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => navigateToAddPlant(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/flower.png', width: 30),
                    const SizedBox(width: 10),
                    const Text(
                      "FLOWER",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        centerTitle: true,
        title: const Text("Home", style: TextStyle(fontSize: 24)),
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
      body: Stack(
        children: [
          Consumer<TransectionProvider>(
            builder: (context, provider, child) {
              var transections = provider.transections;
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: transections.length + 1, // เพิ่ม 1 เพื่อรวมปุ่ม +
                itemBuilder: (context, index) {
                  if (index == transections.length) {
                    // ถ้าเป็นช่องสุดท้าย ให้แสดงปุ่ม +
                    return GestureDetector(
                      onTap: () => showCategoryPopup(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.brown[800],
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 5),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.add, size: 40, color: Colors.white),
                        ),
                      ),
                    );
                  }

                  var transaction = transections[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.brown[300],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 5),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/tree.png', width: 80),
                        const SizedBox(height: 8),
                        Text(
                          transaction.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class AddPlantPage extends StatefulWidget {
  const AddPlantPage({super.key});

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
                Transaction statement = Transaction(
                  name: name,
                  type: type,
                  date:
                      selectedDate ??
                      DateTime.now(), // ใช้วันที่เลือก หรือวันที่ปัจจุบัน
                );

                // เรียก provider เพื่อบันทึกข้อมูล
                var provider = Provider.of<TransectionProvider>(
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
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
                      ['ต้นไม้ 1', 'ต้นไม้ 2']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (value) {
                    typeController.text =
                        value ?? ""; // อัพเดต controller สำหรับชนิดต้นไม้
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
