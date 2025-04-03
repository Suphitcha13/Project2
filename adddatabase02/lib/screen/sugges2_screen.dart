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
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'ไม่สามารถเปิดลิงก์ได้: $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('บทความแนะนำ'),
        backgroundColor: Colors.lightGreen,
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
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.asset(
                      item['image']!,
                      height: 160,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      item['title']!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
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
