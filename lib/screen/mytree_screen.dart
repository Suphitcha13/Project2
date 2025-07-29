import 'package:flutter/material.dart';
import 'package:app/structure/plant.dart';
import 'package:app/main.dart';
import 'package:app/screen/sugges_screen.dart';
import 'package:app/structure/background_container.dart';
import 'package:app/bluetooth/bluetooth_manager.dart';

class PlantPage extends StatefulWidget {
  final Plant plant;

  const PlantPage({Key? key, required this.plant}) : super(key: key);

  @override
  _PlantPageState createState() => _PlantPageState();
}

class _PlantPageState extends State<PlantPage> with TickerProviderStateMixin {
  // Bluetooth Manager
  final BluetoothManager _bluetoothManager = BluetoothManager();

  double temperature = 0.0;
  int soilMoisture = 0;
  late AnimationController _slideController;
  late AnimationController _fadeController;

  // เพิ่มตัวแปรสำหรับเช็คว่าพืชนี้เชื่อมต่ออยู่หรือไม่
  bool get isThisPlantConnected =>
      _bluetoothManager.isConnected &&
      _bluetoothManager.connectedPlantName == widget.plant.name;

  bool get isOtherPlantConnected =>
      _bluetoothManager.isConnected &&
      _bluetoothManager.connectedPlantName != widget.plant.name;

  // เพิ่มฟังก์ชันเหล่านี้ใน _PlantPageState class

  // ฟังก์ชันดึงค่าอุณหภูมิ
  int _getCurrentTemperature() {
    if (isThisPlantConnected && _bluetoothManager.latestData != null) {
      return _bluetoothManager.latestData!.temperature;
    }
    return 0; // ค่าเริ่มต้นถ้าไม่ได้เชื่อมต่อ
  }

  // ฟังก์ชันดึงค่าความชื้น
  int _getCurrentSoilMoisture() {
    if (isThisPlantConnected && _bluetoothManager.latestData != null) {
      return _bluetoothManager.latestData!.soilMoisture;
    }
    return 0; // ค่าเริ่มต้นถ้าไม่ได้เชื่อมต่อ
  }

  // ฟังก์ชันแสดงค่าอุณหภูมิ
  String _getTemperatureValue() {
    if (isThisPlantConnected && _bluetoothManager.latestData != null) {
      return "${_bluetoothManager.latestData!.temperature.toStringAsFixed(1)}°C";
    }
    return "0.0°C"; // แสดง 0 ถ้าไม่ได้เชื่อมต่อ
  }

  // ฟังก์ชันแสดงค่าความชื้น
  String _getSoilMoistureValue() {
    if (isThisPlantConnected && _bluetoothManager.latestData != null) {
      return "${_bluetoothManager.latestData!.soilMoisture}%";
    }
    return "0%"; // แสดง 0 ถ้าไม่ได้เชื่อมต่อ
  }

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
    _bluetoothManager.addListener(_updateSensorData);
    _initializeApp();
  }

  void _initializeApp() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _bluetoothManager.addListener(_onBluetoothStateChanged);
        _bluetoothManager.initialize();
      }
    });
  }

  void _onBluetoothStateChanged() {
    if (mounted) {
      setState(() {
        // อัปเดตทันทีหลังจากมีการเปลี่ยนแปลงสถานะ
        _updateSensorData();
      });
    }
  }

  void _updateSensorData() {
    // อัปเดตข้อมูลเฉพาะเมื่อต้นไม้นี้เชื่อมต่อกับบลูทูธ
    if (isThisPlantConnected) {
      final latest = _bluetoothManager.latestData;
      if (latest != null) {
        setState(() {
          temperature = latest.temperature.toDouble();
          soilMoisture = latest.soilMoisture;
        });
      }
    } else {
      // ถ้าไม่ได้เชื่อมต่อ ให้รีเซ็ตค่าเป็น 0
      setState(() {
        temperature = 0.0;
        soilMoisture = 0;
      });
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _bluetoothManager.removeListener(_onBluetoothStateChanged);
    _bluetoothManager.removeListener(_updateSensorData);
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

  Widget _buildBluetoothButton() {
    return Container(
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
      child: IconButton(
        onPressed: () async {
          // หากพืชนี้เชื่อมต่ออยู่แล้ว ให้ตัดการเชื่อมต่อ
          if (isThisPlantConnected) {
            _showDisconnectConfirmDialog();
            return;
          }

          // แสดง Bluetooth Selection Dialog
          await _showBluetoothSelectionDialog();

          // อัพเดต state หลังจากปิด dialog
          if (mounted) {
            setState(() {});
          }
        },
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              isThisPlantConnected
                  ? Icons.bluetooth_connected
                  : Icons.bluetooth,
              color: Colors.blue.shade700,
              size: 24,
            ),
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _getBluetoothStatusColor(),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        tooltip:
            isThisPlantConnected ? 'ตัดการเชื่อมต่อ' : 'เชื่อมต่อเซ็นเซอร์',
      ),
    );
  }

  // Method สำหรับแสดง Bluetooth Selection Dialog - แก้ไขใหม่
  Future<void> _showBluetoothSelectionDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.bluetooth_searching,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text('เลือกเซ็นเซอร์'),
                ],
              ),
              content: Container(
                width: double.maxFinite,
                height: 300,
                child: StreamBuilder(
                  stream: Stream.periodic(const Duration(milliseconds: 500)),
                  builder: (context, snapshot) {
                    return Column(
                      children: [
                        // แสดงสถานะการสแกน
                        if (_bluetoothManager.isScanning)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.3),
                              ),
                            ),
                            child: const Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'กำลังสแกนหาเซ็นเซอร์...',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (_bluetoothManager.isScanning)
                          const SizedBox(height: 16),

                        // แสดงจำนวน device ที่พบ
                        if (_bluetoothManager.availableDevices.isNotEmpty ||
                            !_bluetoothManager.isScanning)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'เซ็นเซอร์ที่พบ:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        _bluetoothManager
                                                .availableDevices
                                                .isNotEmpty
                                            ? Colors.green.withOpacity(0.2)
                                            : Colors.grey.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_bluetoothManager.availableDevices.length} เครื่อง',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          _bluetoothManager
                                                  .availableDevices
                                                  .isNotEmpty
                                              ? Colors.green.shade700
                                              : Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Device List
                        Expanded(
                          child:
                              _bluetoothManager.availableDevices.isEmpty &&
                                      !_bluetoothManager.isScanning
                                  ? _buildEmptyDeviceState()
                                  : ListView.builder(
                                    itemCount:
                                        _bluetoothManager
                                            .availableDevices
                                            .length,
                                    itemBuilder: (context, index) {
                                      final device =
                                          _bluetoothManager
                                              .availableDevices[index];
                                      final isConnectedDevice =
                                          _bluetoothManager.isConnected &&
                                          _bluetoothManager
                                                  .connectedDevice
                                                  ?.name ==
                                              device.name;

                                      return Card(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        elevation: isConnectedDevice ? 4 : 2,
                                        color:
                                            isConnectedDevice
                                                ? Colors.green.withOpacity(0.1)
                                                : null,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          side: BorderSide(
                                            color:
                                                isConnectedDevice
                                                    ? Colors.green.withOpacity(
                                                      0.5,
                                                    )
                                                    : Colors.transparent,
                                            width: 1,
                                          ),
                                        ),
                                        child: ListTile(
                                          leading: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color:
                                                  isConnectedDevice
                                                      ? Colors.green
                                                          .withOpacity(0.2)
                                                      : Colors.blue.withOpacity(
                                                        0.1,
                                                      ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              isConnectedDevice
                                                  ? Icons.bluetooth_connected
                                                  : Icons.bluetooth,
                                              color:
                                                  isConnectedDevice
                                                      ? Colors.green
                                                      : Colors.blue.shade700,
                                              size: 20,
                                            ),
                                          ),
                                          title: Text(
                                            device.name,
                                            style: TextStyle(
                                              fontWeight:
                                                  isConnectedDevice
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                              fontSize: 14,
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    device.signalIcon,
                                                    size: 10,
                                                    color: _getSignalColor(
                                                      device.signalStrength,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${device.signalStrength} dBm',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                  if (isConnectedDevice) ...[
                                                    const SizedBox(width: 8),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                          trailing: SizedBox(
                                            width: 80,
                                            height: 36,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    isConnectedDevice
                                                        ? Colors.red
                                                        : Colors.green,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                elevation:
                                                    isConnectedDevice ? 2 : 1,
                                              ),
                                              onPressed: () async {
                                                Navigator.of(context).pop();

                                                if (isConnectedDevice) {
                                                  _showDisconnectFromDeviceDialog(
                                                    device,
                                                  );
                                                } else {
                                                  await _connectToDevice(
                                                    device,
                                                  );
                                                }
                                              },
                                              child: Text(
                                                isConnectedDevice
                                                    ? 'ตัดการเชื่อมต่อ'
                                                    : 'เชื่อมต่อ',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('ยกเลิก'),
                  onPressed: () {
                    _bluetoothManager.stopScan();
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _bluetoothManager.isScanning
                            ? Colors.orange
                            : Colors.blue.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_bluetoothManager.isScanning) ...[
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('หยุดสแกน'),
                      ] else ...[
                        const Icon(Icons.search, size: 16),
                        const SizedBox(width: 4),
                        const Text('สแกน'),
                      ],
                    ],
                  ),
                  onPressed: () async {
                    if (_bluetoothManager.isScanning) {
                      await _bluetoothManager.stopScan();
                    } else {
                      await _bluetoothManager.startScan();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // เพิ่ม method สำหรับแสดงสถานะเมื่อไม่พบ device
  Widget _buildEmptyDeviceState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bluetooth_searching, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'ไม่พบเซ็นเซอร์',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'กดปุ่ม "สแกน" เพื่อค้นหาเซ็นเซอร์ใหม่',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // เพิ่ม helper method สำหรับสีสัญญาณ
  Color _getSignalColor(int strength) {
    if (strength > -40) return Colors.green;
    if (strength > -55) return Colors.orange;
    return Colors.red;
  }

  // Method สำหรับเชื่อมต่อกับอุปกรณ์ที่เลือก
  Future<void> _connectToDevice(dynamic device) async {
    try {
      // เชื่อมต่อกับอุปกรณ์
      await _bluetoothManager.connectToDevice(device);

      // หลังจากเชื่อมต่อสำเร็จ ให้บันทึก plant name
      if (_bluetoothManager.isConnected) {
        _bluetoothManager.setConnectedPlant(
          widget.plant.name,
          widget.plant.name,
        );
        if (mounted) setState(() {});
      }
    } catch (e) {
      // แสดง error dialog ถ้าเชื่อมต่อไม่สำเร็จ
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('เชื่อมต่อไม่สำเร็จ'),
                content: Text('ไม่สามารถเชื่อมต่อกับ ${device.name} ได้'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('ตกลง'),
                  ),
                ],
              ),
        );
      }
    }
  }

  // Method สำหรับแสดง dialog เมื่อต้องการตัดการเชื่อมต่อจากอุปกรณ์ที่เชื่อมต่ออยู่
  void _showDisconnectFromDeviceDialog(dynamic device) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange, size: 24),
              const SizedBox(width: 8),
              const Text('มีการเชื่อมต่ออยู่แล้ว'),
            ],
          ),
          content: Text(
            'ขณะนี้ "${device.name}" เชื่อมต่อกับ "${_bluetoothManager.connectedPlantName}" อยู่แล้ว\n'
            'ต้องการตัดการเชื่อมต่อและเชื่อมกับ "${widget.plant.name}" หรือไม่?',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('ตัดการเชื่อมต่อและเชื่อมใหม่'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _bluetoothManager.disconnect();
                await _connectToDevice(device);
              },
            ),
          ],
        );
      },
    );
  }

  // แสดง dialog เมื่อมีพืชอื่นเชื่อมต่ออยู่
  void _showDisconnectConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.bluetooth_disabled, color: Colors.red, size: 24),
              const SizedBox(width: 8),
              const Text('ตัดการเชื่อมต่อ'),
            ],
          ),
          content: Text(
            'ต้องการตัดการเชื่อมต่อกับ "${widget.plant.name}" หรือไม่?',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('ตัดการเชื่อมต่อ'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _bluetoothManager.disconnect();

                // รีเซ็ตค่าเซ็นเซอร์เป็น 0 หลังตัดการเชื่อมต่อ
                if (mounted) {
                  setState(() {
                    temperature = 0.0;
                    soilMoisture = 0;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildBluetoothStatusBar() {
    // ไม่แสดงอะไรเลยถ้าพืชนี้ยังไม่เชื่อมต่อ
    if (!isThisPlantConnected) {
      return const SizedBox.shrink();
    }

    // แสดง status bar แบบสวยเมื่อพืชนี้เชื่อมต่อแล้ว
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sensors, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            _bluetoothManager.connectedDevice?.name ?? "เชื่อมต่อแล้ว",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 9,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  // เพิ่ม method สำหรับแสดง Bluetooth Status Bar ในส่วน content

  Color _getBluetoothStatusColor() {
    switch (_bluetoothManager.status) {
      case BluetoothConnectionStatus.connected:
        return isThisPlantConnected ? Colors.green : Colors.grey;
      case BluetoothConnectionStatus.connecting:
        return Colors.blue;
      case BluetoothConnectionStatus.error:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // เพิ่ม method สำหรับแสดงสถานะ Bluetooth ใน AppBar

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
                      width: 100,
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

                    // ส่วนกลาง - Title และ Bluetooth Status
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeController,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
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
                            const SizedBox(height: 4),
                            _buildBluetoothStatusBar(),
                          ],
                        ),
                      ),
                    ),

                    // ส่วนขวา - ปุ่มคำแนะนำ
                    SizedBox(
                      width: 100,
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
                  // โค้ดตามที่คุณให้มา
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
                      // Header Section
                      Row(
                        children: [
                          Expanded(
                            child: Row(
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
                          ),
                          Row(children: [_buildBluetoothButton()]),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // Temperature & Humidity Row
                      // Temperature & Humidity Row - แก้ไขส่วนนี้
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatusCard(
                              icon: "🌡️",
                              title: "อุณหภูมิ",
                              value: _getTemperatureValue(),
                              color: getStatusColor(
                                _getCurrentTemperature(),
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
                              title: "ความชื้นในดิน",
                              value: _getSoilMoistureValue(),
                              color: getStatusColor(
                                _getCurrentSoilMoisture(),
                                'soil',
                              ),
                              gradient: [
                                const Color(0xFF4CAF50).withOpacity(0.1),
                                const Color(0xFF81C784).withOpacity(0.05),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),
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
