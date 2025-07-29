import 'package:app/main.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Suggest2Page extends StatelessWidget {
  final List<Map<String, String>> suggestions = [
    {
      'title': '20 ต้นไม้มงคลรวยทรัพย์ เศรษฐีรวยทรัพย์ ที่ควรปลูกไว้ในบ้าน',
      'image': 'assets/sugges2/money.jpg',
      'url':
          'https://www.jorakay.co.th/blog/owner/other/12-sacred-trees-rich-in-wealth-suitable-for-planting-in-the-house',
    },
    {
      'title': 'ต้นไม้ในร่ม ทน ดูแลง่าย และปลูกในห้องน้ำได้',
      'image': 'assets/sugges2/bath.jpg',
      'url':
          'https://www.baanlaesuan.com/313244/plant-scoop/indoor-toilet-plant/',
    },
    {
      'title':
          '10 ต้นไม้ฟอกอากาศ ที่ช่วยดูดสารพิษ คืนอากาศบริสุทธิ์ให้แก่ห้องนอนของคุณ',
      'image': 'assets/sugges2/air.jpg',
      'url':
          'https://www.apthai.com/th/blog/living-series/designanddecor-air-purifying-plants-for-bedroom',
    },
    {
      'title': '10 ไม้ดอกไม้ประดับปลูกง่าย โตเร็ว นิยมปลูกหน้าบ้านสวย สีสดใส',
      'image': 'assets/sugges2/10flow.jpg',
      'url': 'https://www.scasset.com/th/blog/inspiration/easy-grow-flowers/',
    },
    {
      'title': 'เรื่องดอกๆ บอกฟรีเบิร์ด 10 ดอกไม้สะพรั่งบานในต่างแดน',
      'image': 'assets/sugges2/flowinter.jpg',
      'url':
          'https://www.freebirdtour.com/17168980/%E0%B9%80%E0%B8%A3%E0%B8%B7%E0%B9%88%E0%B8%AD%E0%B8%87%E0%B8%94%E0%B8%AD%E0%B8%81%E0%B9%86-%E0%B8%9A%E0%B8%AD%E0%B8%81%E0%B8%9F%E0%B8%A3%E0%B8%B5%E0%B9%80%E0%B8%9A%E0%B8%B4%E0%B8%A3%E0%B9%8C%E0%B8%94-10-%E0%B8%94%E0%B8%AD%E0%B8%81%E0%B9%84%E0%B8%A1%E0%B9%89%E0%B8%AA%E0%B8%B0%E0%B8%9E%E0%B8%A3%E0%B8%B1%E0%B9%88%E0%B8%87%E0%B8%9A%E0%B8%B2%E0%B8%99%E0%B9%83%E0%B8%99%E0%B8%95%E0%B9%88%E0%B8%B2%E0%B8%87%E0%B9%81%E0%B8%94%E0%B8%99',
    },
  ];

  void _openUrl(String url) async {
    try {
      final uri = Uri.parse(url);

      // ลองเปิดด้วย External Application ก่อน (แนะนำสำหรับมือถือ)
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode:
              LaunchMode.externalApplication, // บังคับให้เปิดใน browser ภายนอก
        );
      } else {
        // ถ้าไม่ได้ ลองเปิดแบบปกติ
        await launchUrl(uri);
      }
    } catch (e) {
      // แสดง error message ที่เป็นมิตรกับผู้ใช้
      debugPrint('Error opening URL: $e');
      // คุณสามารถแสดง SnackBar แทนการ throw error
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('ไม่สามารถเปิดลิงก์ได้')),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65), // ลดความสูงลง
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.green.shade400,
                Colors.teal.shade400,
                Colors.cyan.shade300,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            centerTitle: true,
            elevation: 0,
            automaticallyImplyLeading: false, // ซ่อนปุ่มย้อนกลับถ้ามี
            title: const Text(
              "บทความแนะนำ",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.shade300,
              Colors.green.shade400,
              Colors.teal.shade300,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: 1,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false,
              );
            } else if (index == 2) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('🔔 Coming Soon...'),
                  backgroundColor: Colors.green.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          },
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.6),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 32),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_rounded, size: 28),
              label: 'Sugges',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined, size: 28),
              label: 'Alarm',
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final item = suggestions[index];
          return GestureDetector(
            onTap: () => _openUrl(item['url']!),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Color(0xFFD7CCC8),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.asset(
                      item['image']!,
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 160,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['title']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.open_in_new,
                          size: 18,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
