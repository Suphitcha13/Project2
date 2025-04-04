import 'package:app/provider/plant_provider.dart';
import 'package:app/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:app/structure/background_container.dart'; // <-- เพิ่ม

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            return PlantProvider(); //ใช้providerจัดการสถานะ
          },
        ),
      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: GoogleFonts.kanitTextTheme(), // ใส่ฟอนต์ Kanit ทั้งแอป
        ),
        home: const HomePage(), //หน้าหลักของแอป
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('th', 'TH'),
        ], //กำหนดให้รองรับภาษาอังกฤษและภาษาไทย
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState(); //จัดการสถานะของหน้า
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return HomeScreen(); //แสดง HomeScreen เป็นหน้าหลัก
  }
}
