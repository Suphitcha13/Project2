import 'package:app/main.dart';
import 'package:app/screen/mytree_screen.dart';
import 'package:app/screen/sugges2_screen.dart';
import 'package:flutter/material.dart';
import 'package:app/provider/plant_provider.dart';
import 'package:provider/provider.dart';
import 'package:app/screen/addplantpage_screen.dart';
import 'package:app/structure/background_container.dart'; // ✅ เพิ่ม background

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isEditMode = false;

  void toggleEditMode() {
    setState(() {
      isEditMode = !isEditMode;
    });
  }

  void deletePlant(int index) {
    Provider.of<PlantProvider>(context, listen: false).deletePlant(index);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<PlantProvider>(context, listen: false).initData();
      }
    });
  }

  void navigateToAddPlant(BuildContext context, String category) {
    Future.delayed(Duration.zero, () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddPlantPage(category: category),
        ),
      );
    });
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
                onPressed: () => navigateToAddPlant(context, "TREE"),
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
                onPressed: () => navigateToAddPlant(context, "FLOWER"),
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

  String getImageForType(String type) {
    switch (type) {
      case 'เดซี่':
        return 'assets/daisy.png';
      case 'กุหลาบ':
        return 'assets/rose.PNG';
      case 'กล้วยไม้':
        return 'assets/ochid.png';
      case 'กะเพรา':
        return 'assets/kapera.png';
      case 'พลูด่าง':
        return 'assets/pothos.png';
      case 'กระบองเพชร':
        return 'assets/cac.png';
      default:
        return 'assets/tree.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.lightGreen,
          centerTitle: true,
          title: const Text("Home", style: TextStyle(fontSize: 24)),
          actions: [
            TextButton(
              onPressed: toggleEditMode,
              child: Text(
                isEditMode ? "DONE" : "Edit",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false,
              );
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Suggest2Page()),
              );
            } else if (index == 2) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Coming Soon...')));
            }
          },
          backgroundColor: Colors.lightGreen,
          selectedItemColor: Colors.black,
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Consumer<PlantProvider>(
              builder: (context, provider, child) {
                var plants = provider.plant;
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: plants.length + 1,
                  itemBuilder: (context, index) {
                    if (index == plants.length) {
                      return GestureDetector(
                        onTap: () => showCategoryPopup(context),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.brown[800],
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 5),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    }

                    var plant = plants[index];
                    return Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PlantPage(plant: plant),
                              ),
                            );
                          },
                          child: Container(
                            width: 200, // ✅ ความกว้างของกล่องที่ห่อ Column
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.brown[300],
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 5),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  getImageForType(plant.type),
                                  width: 120,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  plant.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isEditMode)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: GestureDetector(
                              onTap: () => deletePlant(index),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
