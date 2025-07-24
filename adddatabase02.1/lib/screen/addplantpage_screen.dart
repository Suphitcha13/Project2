import 'package:app/main.dart';
import 'package:app/provider/plant_provider.dart';
import 'package:app/structure/background_container.dart';
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

class _AddPlantPageState extends State<AddPlantPage>
    with TickerProviderStateMixin {
  final TextEditingController _dateController = TextEditingController();
  Color selectedBorderColor = const Color(
    0xFF81C784,
  ); // เปลี่ยนสีเริ่มต้นเป็นเขียวพาสเทล
  String? selectedType;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late AnimationController _colorAnimationController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _colorAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _colorAnimation = ColorTween(
      begin: Colors.pink.shade100,
      end: Colors.green.shade100,
    ).animate(_colorAnimationController);

    _colorAnimationController.repeat(reverse: true);
  }

  // ฟังก์ชันสำหรับสร้างสีไล่เฉดตามสีที่เลือก
  List<Color> getAppBarGradientColors() {
    // ถ้าเป็นสีเริ่มต้น (เขียวพาสเทล) ให้ใช้สีเดิม
    if (selectedBorderColor.value == const Color(0xFF81C784).value) {
      return [
        Colors.green.shade400,
        Colors.teal.shade400,
        Colors.cyan.shade300,
      ];
    }

    // ปรับความเข้มและความสว่างของสีที่เลือก
    HSLColor hslColor = HSLColor.fromColor(selectedBorderColor);

    return [
      hslColor
          .withLightness(0.5)
          .withSaturation(0.7)
          .toColor(), // สีแรก - เข้มกว่า
      hslColor.withLightness(0.6).withSaturation(0.6).toColor(), // สีกลาง
      hslColor
          .withLightness(0.7)
          .withSaturation(0.5)
          .toColor(), // สีสุดท้าย - อ่อนกว่า
    ];
  }

  // ปรับแต่ง InputDecoration ให้สวยขึ้น
  InputDecoration buildInputDecoration() {
    return InputDecoration(
      floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: selectedBorderColor, width: 2),
        borderRadius: BorderRadius.circular(20), // ขอบมนมากขึ้น
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: selectedBorderColor, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: selectedBorderColor, width: 3),
        borderRadius: BorderRadius.circular(20),
      ),
      labelStyle: TextStyle(
        color: selectedBorderColor,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _animationController.dispose();
    _colorAnimationController.dispose();
    super.dispose();
  }

  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  DateTime? selectedDate;

  // ฟังก์ชันเปิด ColorPicker ที่สวยขึ้น
  void openColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: Row(
            children: [
              Icon(Icons.palette, color: Colors.pink.shade300),
              const SizedBox(width: 8),
              const Text(
                'เลือกสีกรอบ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ColorPicker(
                pickerColor: selectedBorderColor,
                onColorChanged: (color) {
                  setState(() {
                    selectedBorderColor = color;
                  });
                },
                pickerAreaHeightPercent: 0.8,
                enableAlpha: false,
              ),
            ),
          ),
          actions: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pink.shade300, Colors.purple.shade300],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'ยืนยัน',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // วิดเจ็ตสร้างวงกลมสีที่สวยขึ้น
  Widget _buildColorCircle(Color color, {bool isColorPickerEnabled = false}) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            _animationController.forward().then((_) {
              _animationController.reverse();
            });

            if (isColorPickerEnabled) {
              openColorPicker();
            } else {
              setState(() {
                selectedBorderColor = color;
              });
            }
          },
          child: Transform.scale(
            scale: selectedBorderColor == color ? _scaleAnimation.value : 1.0,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border:
                    selectedBorderColor == color
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
              ),
              child:
                  selectedBorderColor == color
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
            ),
          ),
        );
      },
    );
  }

  // วิดเจ็ตสร้างวงกลมสีรุ้งที่สวยขึ้น
  Widget _buildRainbowColorCircle() {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            _animationController.forward().then((_) {
              _animationController.reverse();
            });
            openColorPicker();
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const SweepGradient(
                colors: [
                  Colors.red,
                  Colors.orange,
                  Colors.yellow,
                  Colors.green,
                  Colors.blue,
                  Colors.indigo,
                  Colors.purple,
                  Colors.red,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.color_lens, color: Colors.white, size: 20),
            ),
          ),
        );
      },
    );
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
        return 'assets/Kapera.png';
      case 'พลูด่าง':
        return 'assets/pothos.png';
      case 'กระบองเพชร':
        return 'assets/cac.png';
      default:
        return 'https://cdn-icons-png.flaticon.com/512/2909/2909769.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Color> appBarColors =
        getAppBarGradientColors(); // เรียกใช้ฟังก์ชันสร้างสีไล่เฉด

    return BackgroundContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80), // เพิ่มความสูงขึ้น
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: appBarColors, // ใช้สีไล่เฉดที่เปลี่ยนตามสีที่เลือก
                stops: const [0.0, 0.5, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      selectedBorderColor.value == const Color(0xFF81C784).value
                          ? Colors.green.withOpacity(0.3) // สีเงาเริ่มต้น
                          : selectedBorderColor.withOpacity(
                            0.3,
                          ), // เปลี่ยนสีเงาตามสีที่เลือก
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    // ปุ่มย้อนกลับที่สวยขึ้น
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 45,
                            height: 45,
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Title เหมือนเดิม
                    const Expanded(
                      child: Text(
                        "Add your plant",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // ปุ่ม Save ที่สวยขึ้น
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.white.withOpacity(0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            if (formKey.currentState!.validate()) {
                              var name = nameController.text;
                              var type = typeController.text;

                              Plant statement = Plant(
                                name: name,
                                type: type,
                                date: selectedDate ?? DateTime.now(),
                                color: selectedBorderColor,
                              );

                              var provider = Provider.of<PlantProvider>(
                                context,
                                listen: false,
                              );
                              provider.addPlant(statement);

                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomePage(),
                                ),
                                (Route<dynamic> route) => false,
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        body: Container(
          child: SafeArea(
            child: Column(
              children: [
                // Body content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),

                          // Hero Section - Plant Form Card (ใช้สไตล์จาก Plant Info Card)
                          Container(
                            margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white,
                                  Colors.white.withOpacity(0.9),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: selectedBorderColor.withOpacity(0.3),
                                  spreadRadius: 0,
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Plant Image Section (แสดงเฉพาะเมื่อเลือกชนิดแล้ว)
                                if (selectedType != null)
                                  Container(
                                    padding: const EdgeInsets.all(30),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          selectedBorderColor.withOpacity(0.1),
                                          Colors.transparent,
                                        ],
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(25),
                                        topRight: Radius.circular(25),
                                      ),
                                    ),
                                    child: Center(
                                      child: Hero(
                                        tag: 'plant_form_image',
                                        child: Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: selectedBorderColor
                                                    .withOpacity(0.2),
                                                spreadRadius: 0,
                                                blurRadius: 15,
                                                offset: const Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: Image.asset(
                                            getTreeImage(selectedType!),
                                            height: 120,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                // Form Fields Section (ใช้สไตล์จาก Plant Details)
                                Padding(
                                  padding:
                                      selectedType != null
                                          ? const EdgeInsets.fromLTRB(
                                            20,
                                            0,
                                            20,
                                            30,
                                          )
                                          : const EdgeInsets.fromLTRB(
                                            20,
                                            30,
                                            20,
                                            30,
                                          ),
                                  child: Column(
                                    children: [
                                      // ชื่อต้นไม้
                                      TextFormField(
                                        controller: nameController,
                                        decoration: buildInputDecoration()
                                            .copyWith(
                                              labelText: 'ชื่อต้นไม้',
                                              prefixIcon: Icon(
                                                Icons.nature,
                                                color: selectedBorderColor,
                                              ),
                                            ),
                                        validator: (String? str) {
                                          if (str == null || str.isEmpty) {
                                            return "กรุณากรอกชื่อต้นไม้";
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),

                                      // เลือกชนิดต้นไม้
                                      DropdownButtonFormField<String>(
                                        decoration: buildInputDecoration()
                                            .copyWith(
                                              labelText: 'เลือกชนิดต้นไม้',
                                              prefixIcon: Icon(
                                                Icons.local_florist,
                                                color: selectedBorderColor,
                                              ),
                                            ),
                                        items:
                                            widget.category == "TREE"
                                                ? [
                                                      'กะเพรา',
                                                      'พลูด่าง',
                                                      'กระบองเพชร',
                                                    ]
                                                    .map(
                                                      (e) => DropdownMenuItem(
                                                        value: e,
                                                        child: Text(e),
                                                      ),
                                                    )
                                                    .toList()
                                                : [
                                                      'กุหลาบ',
                                                      'เดซี่',
                                                      'กล้วยไม้',
                                                    ]
                                                    .map(
                                                      (e) => DropdownMenuItem(
                                                        value: e,
                                                        child: Text(e),
                                                      ),
                                                    )
                                                    .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedType = value;
                                            typeController.text = value ?? '';
                                          });
                                        },
                                        dropdownColor: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      const SizedBox(height: 16),

                                      // วันที่ปลูก
                                      TextField(
                                        controller: dateController,
                                        readOnly: true,
                                        decoration: buildInputDecoration()
                                            .copyWith(
                                              labelText: 'วันที่เริ่มปลูก',
                                              prefixIcon: Icon(
                                                Icons.calendar_today,
                                                color: selectedBorderColor,
                                              ),
                                              suffixIcon: Icon(
                                                Icons.date_range,
                                                color: selectedBorderColor,
                                              ),
                                            ),
                                        onTap: () async {
                                          DateTime?
                                          pickedDate = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                            builder: (context, child) {
                                              return Theme(
                                                data: Theme.of(
                                                  context,
                                                ).copyWith(
                                                  colorScheme:
                                                      ColorScheme.light(
                                                        primary:
                                                            selectedBorderColor,
                                                        onPrimary: Colors.white,
                                                        surface: Colors.white,
                                                        onSurface: Colors.black,
                                                      ),
                                                ),
                                                child: child!,
                                              );
                                            },
                                          );

                                          if (pickedDate != null) {
                                            dateController.text =
                                                '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
                                            setState(() {
                                              selectedDate = pickedDate;
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // เลือกสีกรอบ (ใช้การ์ดแยกเหมือนเดิม)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.palette,
                                      color: Colors.pink.shade300,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'เลือกสีกรอบ',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildRainbowColorCircle(),
                                    _buildColorCircle(Colors.pink.shade300),
                                    _buildColorCircle(Colors.green.shade300),
                                    _buildColorCircle(Colors.yellow.shade300),
                                    _buildColorCircle(Colors.purple.shade300),
                                    _buildColorCircle(Colors.blue.shade300),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Navigation Bar ที่น่ารัก
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: appBarColors, // ใช้สีไล่เฉดเหมือน AppBar
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            selectedBorderColor.value ==
                                    const Color(0xFF81C784).value
                                ? Colors.green.withOpacity(0.3) // สีเงาเริ่มต้น
                                : selectedBorderColor.withOpacity(
                                  0.3,
                                ), // เปลี่ยนสีเงาตามสีที่เลือก
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
