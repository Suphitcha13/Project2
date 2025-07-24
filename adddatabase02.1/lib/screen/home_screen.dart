import 'package:app/screen/mytree_screen.dart';
import 'package:app/screen/sugges2_screen.dart';
import 'package:flutter/material.dart';
import 'package:app/provider/plant_provider.dart';
import 'package:provider/provider.dart';
import 'package:app/screen/addplantpage_screen.dart';
import 'package:app/structure/background_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool isEditMode = false;
  List<AnimationController> shakeControllers = [];
  List<Animation<double>> shakeAnimations = [];

  void toggleEditMode() {
    setState(() {
      isEditMode = !isEditMode;
    });

    if (isEditMode) {
      // Start shake animation when entering edit mode
      for (var controller in shakeControllers) {
        controller.repeat(reverse: true);
      }
    } else {
      // Stop animation when exiting edit mode
      for (var controller in shakeControllers) {
        controller.stop();
        controller.reset();
      }
    }
  }

  void deletePlant(int index) {
    // Show confirmation dialog before deleting
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF8B4513),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.white, width: 2),
          ),
          title: const Text(
            "🗑️ Delete Plant",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            "Are you sure you want to delete this plant? 🌱",
            style: TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          actions: [
            Container(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Provider.of<PlantProvider>(
                          context,
                          listen: false,
                        ).deletePlant(index);

                        // Reinitialize animations after deletion with proper timing
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted && isEditMode) {
                            _initializeAnimations();
                            // Double check - force rebuild and restart animations
                            setState(() {});

                            // Additional safety check to restart animations
                            Future.delayed(
                              const Duration(milliseconds: 50),
                              () {
                                if (mounted &&
                                    isEditMode &&
                                    shakeControllers.isNotEmpty) {
                                  for (var controller in shakeControllers) {
                                    if (!controller.isAnimating) {
                                      controller.repeat(reverse: true);
                                    }
                                  }
                                }
                              },
                            );
                          }
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Delete",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<PlantProvider>(context, listen: false).initData();
        _initializeAnimations();
      }
    });
  }

  void _initializeAnimations() {
    final provider = Provider.of<PlantProvider>(context, listen: false);
    final wasInEditMode = isEditMode; // Store current edit mode state

    // Dispose existing controllers properly
    for (var controller in shakeControllers) {
      if (controller.isAnimating) {
        controller.stop();
      }
      controller.dispose();
    }

    shakeControllers.clear();
    shakeAnimations.clear();

    // Create new controllers for each plant
    for (int i = 0; i < provider.plant.length; i++) {
      AnimationController controller = AnimationController(
        duration: Duration(
          milliseconds: 180 + (i % 3) * 20,
        ), // Varied duration for more natural look
        vsync: this,
      );

      // Add random offset for more natural shake
      double beginValue = -0.015 - (i % 2) * 0.005;
      double endValue = 0.015 + (i % 2) * 0.005;

      Animation<double> animation = Tween<double>(
        begin: beginValue,
        end: endValue,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

      shakeControllers.add(controller);
      shakeAnimations.add(animation);
    }

    // If we were in edit mode before reinitializing, restart animations immediately
    if (wasInEditMode && shakeControllers.isNotEmpty) {
      // Start animations after a tiny delay to ensure they're properly initialized
      Future.microtask(() {
        for (var controller in shakeControllers) {
          if (mounted && isEditMode) {
            controller.repeat(reverse: true);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in shakeControllers) {
      if (controller.isAnimating) {
        controller.stop();
      }
      controller.dispose();
    }
    super.dispose();
  }

  void navigateToAddPlant(BuildContext context, String category) {
    Navigator.of(context).pop(); // Close the dialog first
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPlantPage(category: category)),
    ).then((_) {
      // Reinitialize animations when returning from add plant page
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _initializeAnimations();
        }
      });
    });
  }

  void showCategoryPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF8B4513),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.white, width: 2),
          ),
          title: const Text(
            "🌱 SELECT CATEGORIES",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              _buildCategoryButton(context, "TREE", 'assets/images/tree.png'),
              const SizedBox(height: 12),
              _buildCategoryButton(
                context,
                "FLOWER",
                'assets/images/flower.png',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryButton(
    BuildContext context,
    String category,
    String imagePath,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => navigateToAddPlant(context, category),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF8B4513),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          elevation: 3,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 30,
              height: 30,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.image_not_supported,
                  size: 30,
                  color: Colors.grey,
                );
              },
            ),
            const SizedBox(width: 10),
            Text(
              category,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B4513),
              ),
            ),
          ],
        ),
      ),
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
        return 'assets/Kapera.png';
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
                "Home",
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
                  child: TextButton(
                    onPressed: toggleEditMode,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      isEditMode ? "DONE" : "Edit",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
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
            currentIndex: 0,
            onTap: (index) {
              if (index == 0) {
                // Already on home screen, no need to navigate
                return;
              } else if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Suggest2Page()),
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
                icon: Icon(Icons.home_rounded, size: 28),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline_rounded, size: 28),
                label: 'Suggest',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_outlined, size: 28),
                label: 'Alarm',
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Consumer<PlantProvider>(
              builder: (context, provider, child) {
                var plants = provider.plant;

                // Update animation controllers when plant count changes
                if (shakeControllers.length != plants.length && mounted) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _initializeAnimations();
                      // Ensure animations continue if in edit mode
                      if (isEditMode) {
                        setState(() {});
                      }
                    }
                  });
                }

                return Column(
                  children: [
                    // Header with plant count
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "🌿 My Garden",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.shade300,
                                  Colors.green.shade400,
                                  Colors.teal.shade300,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${plants.length} plants",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Grid view
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.85,
                            ),
                        itemCount: plants.length + 1,
                        itemBuilder: (context, index) {
                          if (index == plants.length) {
                            return _buildAddPlantCard(context);
                          }

                          var plant = plants[index];
                          return _buildPlantCard(context, plant, index);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddPlantCard(BuildContext context) {
    return GestureDetector(
      onTap: () => showCategoryPopup(context),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade300,
              Colors.green.shade400,
              Colors.teal.shade300,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 32,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '🌱 Add Plant',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantCard(BuildContext context, plant, int index) {
    // Use modulo to prevent index out of range errors
    final animationIndex =
        shakeAnimations.isNotEmpty ? index % shakeAnimations.length : 0;
    final Animation<double> currentAnimation =
        shakeAnimations.isNotEmpty
            ? shakeAnimations[animationIndex]
            : const AlwaysStoppedAnimation(0.0);

    return AnimatedBuilder(
      animation:
          isEditMode ? currentAnimation : const AlwaysStoppedAnimation(0.0),
      builder: (context, child) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () {
                if (!isEditMode) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PlantPage(plant: plant)),
                  );
                }
              },
              child: Transform.rotate(
                angle: isEditMode ? currentAnimation.value : 0.0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors:
                          isEditMode
                              ? [
                                Colors.brown[300]!.withOpacity(0.6),
                                Colors.brown[400]!.withOpacity(0.6),
                              ]
                              : [Colors.white, Colors.grey[50]!],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.green.shade300.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Transform.rotate(
                          angle: isEditMode ? -currentAnimation.value : 0.0,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: isEditMode ? 0.5 : 1.0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset(
                                getImageForType(plant.type),
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.image_not_supported,
                                    size: 60,
                                    color: Colors.grey,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        flex: 1,
                        child: Transform.rotate(
                          angle: isEditMode ? -currentAnimation.value : 0.0,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: isEditMode ? 0.5 : 1.0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                plant.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
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
            // Delete button in center
            if (isEditMode)
              Positioned.fill(
                child: Center(
                  child: GestureDetector(
                    onTap: () => deletePlant(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.red, Colors.redAccent],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.delete_forever_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
