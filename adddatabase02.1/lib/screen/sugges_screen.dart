import 'package:flutter/material.dart';
import 'package:app/structure/plant.dart';
import 'package:app/structure/background_container.dart';

class SuggestPage extends StatelessWidget {
  final Plant transaction;

  SuggestPage({Key? key, required this.transaction}) : super(key: key);

  final Map<String, Map<String, String>> careInfo = {
    'พลูด่าง': {
      'แสง': 'ชอบแสงแดดรำไร ไม่ควรโดนแดดจัดโดยตรง เพราะใบอาจไหม้ได้',
      'น้ำ': 'รดน้ำ 2-3 ครั้งต่อสัปดาห์ หรือเมื่อดินเริ่มแห้ง',
      'ดิน': 'ใช้ดินร่วนซุยที่ระบายน้ำดี ผสมกาบมะพร้าวสับหรือทรายหยาบ',
      'ปุ๋ย':
          'ใส่ปุ๋ยละลายช้าเดือนละครั้ง หรือใช้ปุ๋ยน้ำสัปดาห์ละครั้งเพื่อให้ใบเขียวสวย',
      'อุณหภูมิ': 'อยู่ในช่วง 18-30°C หลีกเลี่ยงต่ำกว่า 10°C',
      'ความชื้น':
          'ชอบความชื้นปานกลางถึงสูง (50-70%) โดยเฉพาะในห้องแอร์ควรเช็ดใบ',
    },
    'กระบองเพชร': {
      'แสง': 'ต้องการแสงแดดจัด อย่างน้อย 4-6 ชั่วโมงต่อวัน',
      'น้ำ':
          'รดน้ำเมื่อดินแห้งสนิท สัปดาห์ละครั้งหรือสองครั้ง หลีกเลี่ยงการรดน้ำมาก',
      'ดิน': 'ใช้ดินกระบองเพชรหรือดินร่วนผสมทราย ระบายน้ำดี',
      'ปุ๋ย': 'ใส่ปุ๋ยสูตรสำหรับกระบองเพชร เดือนละครั้งในฤดูร้อน/ฝน',
      'อุณหภูมิ': 'อยู่ในช่วง 18-35°C ไม่ชอบอากาศเย็นต่ำกว่า 10°C',
      'ความชื้น': 'ไม่ชอบความชื้นสูง ควรปลูกในที่อากาศถ่ายเท',
    },
    'กะเพรา': {
      'แสง': 'ต้องการแสงแดดเต็มวัน อย่างน้อย 6-8 ชั่วโมง',
      'น้ำ': 'รดน้ำวันละ 1-2 ครั้ง หลีกเลี่ยงน้ำขัง',
      'ดิน': 'ใช้ดินร่วนซุย หรือดินปนทรายที่ระบายน้ำดี',
      'ปุ๋ย': 'ใส่ปุ๋ยคอกทุก 2-3 สัปดาห์ หรือปุ๋ยสูตรเสมอ (15-15-15)',
      'อุณหภูมิ': 'เหมาะที่ 25-35°C ไม่ต่ำกว่า 15°C',
      'ความชื้น': 'อยู่ที่ 50-70% ไม่ควรชื้นมากจนเกิดเชื้อรา',
    },
    'เดซี่': {
      'แสง': 'ต้องการแสงแดดเต็มวัน หรืออย่างน้อย 4-6 ชั่วโมง',
      'น้ำ': 'รดน้ำวันละครั้ง หรือวันเว้นวัน หากดินยังชื้นอยู่',
      'ดิน': 'ดินร่วนซุย ระบายน้ำดี เช่น ผสมปุ๋ยหมักหรือทราย',
      'ปุ๋ย': 'ใส่ปุ๋ยคอกเดือนละครั้ง หรือปุ๋ยละลายน้ำทุก 2-3 สัปดาห์',
      'อุณหภูมิ': 'เหมาะที่ 15-25°C ไม่ควรเกิน 30°C หรือต่ำกว่า 5°C',
      'ความชื้น': 'ปานกลาง (50-70%) ควรพ่นน้ำเพิ่มหากอากาศแห้ง',
    },
    'กุหลาบ': {
      'แสง': 'ต้องการแสงแดดอย่างน้อย 6 ชั่วโมงต่อวัน',
      'น้ำ':
          'รดน้ำวันละครั้ง หรือ 2-3 วันครั้งช่วงอากาศเย็น หลีกเลี่ยงรดตอนกลางคืน',
      'ดิน': 'ดินร่วนซุย ระบายน้ำดี pH 6.0-6.5 ผสมปุ๋ยคอกหรือหมัก',
      'ปุ๋ย': 'ปุ๋ยอินทรีย์ทุก 2-3 สัปดาห์ และเคมีเร่งดอก 1-2 เดือน',
      'อุณหภูมิ': 'อยู่ที่ 18-30°C',
      'ความชื้น': 'เหมาะที่ 50-70% อากาศร้อนควรพ่นน้ำรอบ ๆ ไม่ฉีดที่ใบ',
    },
    'กล้วยไม้': {
      'แสง': 'แสงแดดรำไร หรือแดดอ่อนตอนเช้า 4-6 ชั่วโมง',
      'น้ำ': 'รดน้ำ 2-3 ครั้ง/สัปดาห์ หรือวันละครั้งในหน้าร้อน',
      'ดิน': 'ใช้วัสดุปลูกโปร่ง เช่น กาบมะพร้าวสับ ถ่านไม้ มอส ไม่ใช้ดินทั่วไป',
      'ปุ๋ย':
          'ปุ๋ยละลายน้ำสูตรเสมอ (20-20-20) ทุก 1-2 สัปดาห์ หรือปุ๋ยฟอสฟอรัสสูงเพื่อกระตุ้นดอก',
      'อุณหภูมิ': 'เหมาะที่ 18-30°C ไม่ควรต่ำกว่า 10°C หรือเกิน 35°C',
      'ความชื้น': 'ต้องการ 50-80% ควรพ่นน้ำหรือใช้ถาดน้ำเพื่อเพิ่มความชื้น',
    },
  };

  String getImageSuggesType(String type) {
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
        return 'assets/tree.png'; // รูป default
    }
  }

  // 🌟 ฟังก์ชันเลือกไอคอนตามหมวดหมู่
  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'แสง':
        return Icons.wb_sunny;
      case 'การรดน้ำ':
        return Icons.water_drop;
      case 'อุณหภูมิ':
        return Icons.thermostat;
      case 'ความชื้น':
        return Icons.opacity;
      case 'ปุ้ย':
        return Icons.scatter_plot;
      default:
        return Icons.eco;
    }
  }

  @override
  Widget build(BuildContext context) {
    final plantCare =
        careInfo[transaction.type] ??
        {'แสง': 'ไม่พบข้อมูล', 'การรดน้ำ': 'ไม่พบข้อมูล'};

    final plantColor = transaction.color;

    return BackgroundContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(280),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  plantColor.withOpacity(0.9),
                  plantColor.withOpacity(0.7),
                  plantColor.withOpacity(0.6),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: plantColor.withOpacity(0.3),
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ปุ่มย้อนกลับ
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
                          onTap: () => Navigator.of(context).pop(),
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
                    // Title
                    Expanded(
                      child: Text(
                        "${transaction.type}",
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
                    SizedBox(width: 45),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Container(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🌿 Header พร้อมไอคอนต้นไม้และชื่อ
                  Container(
                    margin: EdgeInsets.only(bottom: 24),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Color(0xFFF1F8E9)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: plantColor.withOpacity(0.1),
                          blurRadius: 20,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // ไอคอนต้นไม้
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [plantColor, plantColor.withOpacity(0.8)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: plantColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.local_florist,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "คู่มือการดูแล",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "เคล็ดลับการดูแลให้ต้นไม้เติบโตแข็งแรง",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF66BB6A),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 📋 Care Information Cards - แบบ Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.8,
                    children:
                        plantCare.entries.map((entry) {
                          return _buildCareCard(
                            entry.key,
                            entry.value,
                            plantColor,
                          );
                        }).toList(),
                  ),

                  SizedBox(height: 24),

                  // 💡 Quick Tips Section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFBC02D),
                          Color(0xFFF9A825),
                        ], // เหลืองเฉดเข้มอมส้ม
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFF9A825).withOpacity(0.6),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.lightbulb,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              "เคล็ดลับดี ๆ",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        // Tips List
                        Column(
                          children: [
                            _buildTipItem(
                              "สังเกตใบไม้เป็นประจำ",
                              Icons.visibility,
                            ),
                            SizedBox(height: 8),
                            _buildTipItem(
                              "รดน้ำตามความต้องการ",
                              Icons.water_drop,
                            ),
                            SizedBox(height: 8),
                            _buildTipItem("ย้ายไปตามแสงแดด", Icons.wb_sunny),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // 🎉 Motivational Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF66BB6A),
                          Color(0xFF388E3C),
                        ], // เปลี่ยนเป็นสีเขียว
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Color(
                            0xFF388E3C,
                          ).withOpacity(0.3), // เปลี่ยนสี shadow เป็นเขียวเข้ม
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Icon รูปหัวใจ
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ดูแลด้วยรัก",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "การดูแลด้วยใจรักจะทำให้ต้นไม้เติบโตสวยงาม และคุณก็จะมีความสุขไปด้วย!",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.95),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method สำหรับสร้าง Care Card
  Widget _buildCareCard(String title, String content, Color plantColor) {
    IconData icon;
    Color cardColor;

    // กำหนดไอคอนและสีตามประเภท
    switch (title) {
      case 'แสง':
        icon = Icons.wb_sunny;
        cardColor = Color(0xFFFFB74D);
        break;
      case 'น้ำ':
        icon = Icons.water_drop;
        cardColor = Color(0xFF42A5F5);
        break;
      case 'อุณหภูมิ':
        icon = Icons.thermostat;
        cardColor = Color(0xFFEF5350);
        break;
      case 'ความชื้น':
        icon = Icons.opacity;
        cardColor = Color(0xFF66BB6A);
        break;
      case 'ปุ๋ย':
        icon = Icons.scatter_plot;
        cardColor = Color(0xFF6A1B9A);
        break;
      default:
        icon = Icons.grass; // ไอคอนที่เหมาะกับดิน/ต้นไม้
        cardColor = Color(0xFF8D6E63); // สีน้ำตาลเข้ม ไม่ซ้ำกับปุ๋ย
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, cardColor.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardColor.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.1),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon และ Title
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [cardColor, cardColor.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: cardColor.withOpacity(0.3),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // เส้นแบ่ง
            Container(
              height: 2,
              width: 30,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cardColor, cardColor.withOpacity(0.3)],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),

            SizedBox(height: 12),

            // Content
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: cardColor.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Text(
                  content,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF424242),
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method สำหรับสร้าง Tip Item
  Widget _buildTipItem(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.95),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
