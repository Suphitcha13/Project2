import 'package:flutter/material.dart';
import 'package:app/structure/plant.dart';
import 'package:app/main.dart';
import 'package:app/screen/sugges_screen.dart';
import 'package:app/structure/background_container.dart';

class PlantPage extends StatefulWidget {
  final Plant plant;

  const PlantPage({Key? key, required this.plant}) : super(key: key);

  @override
  _PlantPageState createState() => _PlantPageState();
}

class _PlantPageState extends State<PlantPage> with TickerProviderStateMixin {
  double temperature = 30.0;
  int humidity = 53;
  int soilMoisture = 40;
  late AnimationController _slideController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  String getSoilMoistureImage(int moisture) {
    if (moisture <= 0) return 'assets/0.png';
    if (moisture <= 25) return 'assets/25.png';
    if (moisture <= 50) return 'assets/50.png';
    if (moisture <= 75) return 'assets/75.png';
    return 'assets/100.png';
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
        return 'assets/tree.png';
    }
  }

  Color getStatusColor(int value, String type) {
    switch (type) {
      case 'temperature':
        if (value >= 25 && value <= 35) return Colors.green;
        if (value < 20 || value > 40) return Colors.red;
        return Colors.orange;
      case 'humidity':
        if (value >= 40 && value <= 70) return Colors.green;
        if (value < 30 || value > 80) return Colors.red;
        return Colors.orange;
      case 'soil':
        if (value >= 50 && value <= 80) return Colors.green;
        if (value < 30) return Colors.red;
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.plant.color.withOpacity(0.9),
                  widget.plant.color.withOpacity(0.7),
                  widget.plant.color.withOpacity(0.6),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.plant.color.withOpacity(0.3),
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
                    // ส่วนซ้าย - ปุ่มย้อนกลับ
                    SizedBox(
                      width: 100, // กำหนดความกว้างคงที่
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
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
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomePage(),
                                  ),
                                  (route) => false,
                                );
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
                      ),
                    ),

                    // ส่วนกลาง - Title
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeController,
                        child: Text(
                          "${widget.plant.name}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 4,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ส่วนขวา - ปุ่มคำแนะนำ
                    SizedBox(
                      width: 100, // กำหนดความกว้างเท่ากับส่วนซ้าย
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => SuggestPage(
                                          transaction: widget.plant,
                                        ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.tips_and_updates,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      "คำแนะนำ",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
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
        body: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _slideController,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Hero Section - Plant Info Card
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white, Colors.white.withOpacity(0.9)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: widget.plant.color.withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Plant Image Section
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              widget.plant.color.withOpacity(0.1),
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
                            tag: 'plant_${widget.plant.name}',
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.plant.color.withOpacity(0.2),
                                    spreadRadius: 0,
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                getTreeImage(widget.plant.type),
                                height: 120,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Plant Details
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                        child: Column(
                          children: [
                            _buildModernInfoCard(
                              icon: Icons.badge_outlined,
                              label: "ชื่อต้นไม้",
                              value: widget.plant.name,
                              color: const Color(0xFF6366F1),
                            ),
                            const SizedBox(height: 12),
                            _buildModernInfoCard(
                              icon: Icons.eco,
                              label: "ชนิดพืช",
                              value: widget.plant.type,
                              color: const Color(0xFF10B981),
                            ),
                            const SizedBox(height: 12),
                            _buildModernInfoCard(
                              icon: Icons.calendar_today,
                              label: "วันที่ปลูก",
                              value:
                                  "${widget.plant.date.day}/${widget.plant.date.month}/${widget.plant.date.year}",
                              color: const Color(0xFFF59E0B),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Status Dashboard
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white, Colors.grey.shade50],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        spreadRadius: 0,
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  widget.plant.color.withOpacity(0.8),
                                  widget.plant.color.withOpacity(0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.analytics,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "สถานะของพืช",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // Temperature & Humidity Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatusCard(
                              icon: "🌡️",
                              title: "อุณหภูมิ",
                              value: "${temperature.toStringAsFixed(1)}°C",
                              color: getStatusColor(
                                temperature.toInt(),
                                'temperature',
                              ),
                              gradient: [
                                const Color(0xFFFF6B6B).withOpacity(0.1),
                                const Color(0xFFFF8E8E).withOpacity(0.05),
                              ],
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildStatusCard(
                              icon: "💧",
                              title: "ความชื้นอากาศ",
                              value: "$humidity%",
                              color: getStatusColor(humidity, 'humidity'),
                              gradient: [
                                const Color(0xFF4FC3F7).withOpacity(0.1),
                                const Color(0xFF81D4FA).withOpacity(0.05),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // Soil Moisture
                      _buildStatusCard(
                        icon: "🌱",
                        title: "ความชื้นในดิน",
                        value: "$soilMoisture%",
                        color: getStatusColor(soilMoisture, 'soil'),
                        gradient: [
                          const Color(0xFF4CAF50).withOpacity(0.1),
                          const Color(0xFF81C784).withOpacity(0.05),
                        ],
                        isWide: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required String icon,
    required String title,
    required String value,
    required Color color,
    required List<Color> gradient,
    bool isWide = false,
  }) {
    return Container(
      width: isWide ? double.infinity : null,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            isWide ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isWide ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.circle, color: Colors.white, size: 8),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
            textAlign: isWide ? TextAlign.center : TextAlign.start,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: isWide ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: isWide ? TextAlign.center : TextAlign.start,
          ),
        ],
      ),
    );
  }
}
