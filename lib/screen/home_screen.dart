import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/plant_provider.dart';
import 'package:app/structure/background_container.dart';
import 'package:app/screen/addplantpage_screen.dart';
import 'package:app/screen/mytree_screen.dart';
import 'package:app/screen/sugges2_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Animation Controllers
  late final AnimationController _editModeController;
  final List<AnimationController> _shakeControllers = [];
  final List<Animation<double>> _shakeAnimations = [];

  // State variables
  bool _isEditMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeEditModeAnimation();
    _loadInitialData();
  }

  /// Initialize edit mode animation controller
  void _initializeEditModeAnimation() {
    _editModeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  /// Load initial data from provider
  Future<void> _loadInitialData() async {
    try {
      // โหลดข้อมูลต้นไม้จากฐานข้อมูล
      context.read<PlantProvider>().initData();

      // รอให้ initData เสร็จสิ้น (เนื่องจาก initData เป็น void แต่ทำงาน async)
      await Future.delayed(const Duration(milliseconds: 100));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Setup animations after data is loaded
        _setupShakeAnimations();
      }
    } catch (e) {
      debugPrint('Error loading plants: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Setup shake animations for plant cards
  void _setupShakeAnimations() {
    if (!mounted) return;

    final plantCount = context.read<PlantProvider>().plant.length;
    final currentCount = _shakeControllers.length;

    // ถ้าจำนวนต้นไม้เท่าเดิม ไม่ต้องทำอะไร
    if (plantCount == currentCount && _isEditMode) {
      return;
    }

    // ถ้าจำนวนลดลง ให้ลบ controllers ส่วนเกินออก
    if (plantCount < currentCount) {
      for (int i = currentCount - 1; i >= plantCount; i--) {
        _shakeControllers[i].dispose();
        _shakeControllers.removeAt(i);
        _shakeAnimations.removeAt(i);
      }
      return; // ไม่ต้อง setup ใหม่
    }

    // ถ้าจำนวนเพิ่มขึ้น ให้เพิ่ม controllers ใหม่
    if (plantCount > currentCount) {
      for (int i = currentCount; i < plantCount; i++) {
        final controller = AnimationController(
          duration: Duration(milliseconds: 180 + (i % 3) * 20),
          vsync: this,
        );

        final animation = Tween<double>(
          begin: -0.02 - (i % 2) * 0.005,
          end: 0.02 + (i % 2) * 0.005,
        ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

        _shakeControllers.add(controller);
        _shakeAnimations.add(animation);

        // เริ่ม animation ทันทีถ้าอยู่ใน edit mode
        if (_isEditMode) {
          controller.repeat(reverse: true);
        }
      }
      return;
    }

    // ถ้าเป็นการ setup ครั้งแรก
    _disposeShakeControllers();

    for (int i = 0; i < plantCount; i++) {
      final controller = AnimationController(
        duration: Duration(milliseconds: 180 + (i % 3) * 20),
        vsync: this,
      );

      final animation = Tween<double>(
        begin: -0.02 - (i % 2) * 0.005,
        end: 0.02 + (i % 2) * 0.005,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

      _shakeControllers.add(controller);
      _shakeAnimations.add(animation);
    }
  }

  /// Dispose shake animation controllers
  void _disposeShakeControllers() {
    for (final controller in _shakeControllers) {
      controller.dispose();
    }
    _shakeControllers.clear();
    _shakeAnimations.clear();
  }

  /// Toggle edit mode
  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });

    if (_isEditMode) {
      _setupShakeAnimations();
      _editModeController.forward();
      _startShakeAnimations();
    } else {
      _editModeController.reverse();
      _stopShakeAnimations();
    }
  }

  /// Start shake animations
  void _startShakeAnimations() {
    for (final controller in _shakeControllers) {
      if (controller.isAnimating) controller.stop();
      controller.repeat(reverse: true);
    }
  }

  /// Stop shake animations
  void _stopShakeAnimations() {
    for (final controller in _shakeControllers) {
      controller.stop();
      controller.reset();
    }
  }

  /// Delete plant with confirmation
  Future<void> _deletePlant(int index) async {
    final confirmed = await _showDeleteConfirmation();
    if (confirmed && mounted) {
      try {
        // Delete plant (PlantProvider.deletePlant เป็น void แต่ทำงาน async)
        context.read<PlantProvider>().deletePlant(index);

        // รอให้การลบเสร็จสิ้น
        await Future.delayed(const Duration(milliseconds: 100));

        // Update UI
        if (mounted) {
          setState(() {});

          // Wait for rebuild to complete
          await Future.delayed(const Duration(milliseconds: 10));

          // Setup animations again
          if (mounted) {
            _setupShakeAnimations();

            // Start animations if in edit mode
            if (_isEditMode) {
              _startShakeAnimations();
            }
          }
        }
      } catch (e) {
        debugPrint('Error deleting plant: $e');
        if (mounted) {
          _showErrorSnackBar('Failed to delete plant');
        }
      }
    }
  }

  /// Show delete confirmation dialog
  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => const _DeleteConfirmationDialog(),
        ) ??
        false;
  }

  /// Show category selection dialog
  void _showCategoryDialog() {
    showDialog(
      context: context,
      builder:
          (context) =>
              _CategorySelectionDialog(onCategorySelected: _navigateToAddPlant),
    );
  }

  /// Navigate to add plant page
  void _navigateToAddPlant(String category) {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPlantPage(category: category)),
    ).then((_) {
      if (mounted) {
        _setupShakeAnimations();
      }
    });
  }

  /// Navigate to suggest page
  void _navigateToSuggest() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Suggest2Page()),
    );
  }

  /// Show coming soon message
  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('🔔 Coming Soon...'),
        backgroundColor: Colors.green.shade600,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Show error message
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Get plant image path
  String _getPlantImage(String type) {
    const imageMap = {
      'เดซี่': 'assets/daisy.png',
      'กุหลาบ': 'assets/rose.PNG',
      'กล้วยไม้': 'assets/ochid.png',
      'กะเพรา': 'assets/Kapera.png',
      'พลูด่าง': 'assets/pothos.png',
      'กระบองเพชร': 'assets/cac.png',
    };
    return imageMap[type] ?? 'assets/tree.png';
  }

  @override
  void dispose() {
    _editModeController.dispose();
    _disposeShakeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(),
        bottomNavigationBar: _buildBottomNavigationBar(),
        body: SafeArea(
          child: _isLoading ? _buildLoadingWidget() : _buildMainBody(),
        ),
      ),
    );
  }

  /// Build loading widget
  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
          SizedBox(height: 16),
          Text(
            'Loading your plants...',
            style: TextStyle(color: Colors.green, fontSize: 16),
          ),
        ],
      ),
    );
  }

  /// Build main body content
  Widget _buildMainBody() {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Consumer<PlantProvider>(
              builder: (context, provider, child) {
                return _buildMainContent(provider);
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Stack(
              alignment: Alignment.center,
              children: [
                const Center(
                  child: Text(
                    "Home",
                    style: TextStyle(
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
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildEditButton(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build edit button
  Widget _buildEditButton() {
    return Container(
      margin: const EdgeInsets.only(right: 2),
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
        onPressed: _toggleEditMode,
        child: Text(
          _isEditMode ? "DONE" : "Edit",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
          ),
        ),
      ),
    );
  }

  /// Build bottom navigation bar
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade300,
            Colors.green.shade400,
            Colors.teal.shade300,
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        onTap: _handleBottomNavTap,
        backgroundColor: Colors.transparent,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.6),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
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
    );
  }

  /// Handle bottom navigation tap
  void _handleBottomNavTap(int index) {
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        _navigateToSuggest();
        break;
      case 2:
        _showComingSoon();
        break;
    }
  }

  /// Build main content
  Widget _buildMainContent(PlantProvider provider) {
    final plants = provider.plant;

    return Column(
      children: [
        _buildHeader(plants.length),
        const SizedBox(height: 16),
        Expanded(child: _buildPlantsGrid(plants)),
      ],
    );
  }

  /// Build header widget
  Widget _buildHeader(int plantCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              "$plantCount plants",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build plants grid
  Widget _buildPlantsGrid(List<dynamic> plants) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: plants.length + 1,
      itemBuilder: (context, index) {
        if (index == plants.length) {
          return _buildAddPlantCard();
        }
        return _buildPlantCard(plants[index], index);
      },
    );
  }

  /// Build add plant card
  Widget _buildAddPlantCard() {
    return GestureDetector(
      onTap: _showCategoryDialog,
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
              'Add Plant',
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

  /// Build plant card
  Widget _buildPlantCard(dynamic plant, int index) {
    final animationIndex =
        _shakeAnimations.isNotEmpty && index < _shakeAnimations.length
            ? index
            : 0;
    final animation =
        _shakeAnimations.isNotEmpty && index < _shakeAnimations.length
            ? _shakeAnimations[animationIndex]
            : const AlwaysStoppedAnimation(0.0);

    return AnimatedBuilder(
      animation: _isEditMode ? animation : const AlwaysStoppedAnimation(0.0),
      builder: (context, child) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () => _handlePlantCardTap(plant),
              child: Transform.rotate(
                angle: _isEditMode ? animation.value : 0.0,
                child: _buildPlantCardContent(plant),
              ),
            ),
            if (_isEditMode) _buildDeleteButton(index),
          ],
        );
      },
    );
  }

  /// Handle plant card tap
  void _handlePlantCardTap(dynamic plant) {
    if (!_isEditMode) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PlantPage(plant: plant)),
      );
    }
  }

  /// Build plant card content
  Widget _buildPlantCardContent(dynamic plant) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey[50]!],
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
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                _getPlantImage(plant.type ?? ''),
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
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                plant.name ?? 'Unknown Plant',
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
        ],
      ),
    );
  }

  /// Build delete button
  Widget _buildDeleteButton(int index) {
    return Positioned.fill(
      child: Center(
        child: GestureDetector(
          onTap: () => _deletePlant(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
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
    );
  }
}

// Dialog Widgets
class _DeleteConfirmationDialog extends StatelessWidget {
  const _DeleteConfirmationDialog();

  @override
  Widget build(BuildContext context) {
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
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(false),
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
                onPressed: () => Navigator.of(context).pop(true),
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
      ],
    );
  }
}

class _CategorySelectionDialog extends StatelessWidget {
  final Function(String) onCategorySelected;

  const _CategorySelectionDialog({required this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
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
          _buildCategoryButton(context, "FLOWER", 'assets/images/flower.png'),
        ],
      ),
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
        onPressed: () => onCategorySelected(category),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF8B4513),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 30,
              height: 30,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image_not_supported, size: 30);
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
}
