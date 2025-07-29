import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';
import 'dart:async';

// Sensor Data Model
class SensorData {
  final int soilMoisture;
  final int temperature;
  final DateTime timestamp;
  List<BluetoothDevice> connectedDevices = [];
  BluetoothDevice? connectedDevice;
  SensorData? latestData;

  SensorData({
    required this.soilMoisture,
    required this.temperature,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory SensorData.fromString(String data) {
    debugPrint('Parsing sensor data: "$data"'); // เพิ่ม debug
    try {
      final values = data.trim().split(' ');
      debugPrint('Split values: $values'); // เพิ่ม debug
      if (values.length >= 2) {
        final moisture = int.parse(values[0]);
        final temp = int.parse(values[1]);
        debugPrint('Parsed - Moisture: $moisture, Temp: $temp'); // เพิ่ม debug
        return SensorData(soilMoisture: moisture, temperature: temp);
      }
    } catch (e) {
      debugPrint('Error parsing sensor data: $e');
    }
    return SensorData(soilMoisture: 0, temperature: 0);
  }

  Map<String, dynamic> toJson() => {
    'soilMoisture': soilMoisture,
    'temperature': temperature,
    'timestamp': timestamp.toIso8601String(),
  };

  @override
  String toString() => 'Moisture: $soilMoisture%, Temp: ${temperature}°C';
}

// Sensor Device Model
class SensorDevice {
  final String name;
  final String address;
  final int signalStrength;
  final BluetoothDevice device;

  SensorDevice({
    required this.name,
    required this.address,
    required this.signalStrength,
    required this.device,
  });

  factory SensorDevice.fromScanResult(ScanResult result) {
    return SensorDevice(
      name:
          result.device.platformName.isEmpty
              ? 'Unknown Device'
              : result.device.platformName,
      address: result.device.remoteId.toString(),
      signalStrength: result.rssi,
      device: result.device,
    );
  }

  // Signal strength indicator
  IconData get signalIcon {
    if (signalStrength > -40) return Icons.signal_cellular_4_bar;
    if (signalStrength > -55) return Icons.signal_cellular_0_bar;
    if (signalStrength > -70) return Icons.signal_cellular_null;
    return Icons.signal_cellular_off;
  }

  @override
  String toString() => 'Device: $name ($address)';
}

// Connection Status
enum BluetoothConnectionStatus {
  disconnected,
  scanning,
  connecting,
  connected,
  error,
}

// Improved Bluetooth Manager
class BluetoothManager extends ChangeNotifier {
  static final BluetoothManager _instance = BluetoothManager._internal();
  factory BluetoothManager() => _instance;
  BluetoothManager._internal();

  // Constants
  static const String serviceUuid = "12345678-1234-1234-1234-123456789012";
  static const String characteristicUuid =
      "87654321-4321-4321-4321-210987654321";
  static const Duration scanTimeout = Duration(seconds: 10);
  static const Duration connectTimeout = Duration(seconds: 15);

  // State variables
  BluetoothConnectionStatus _status = BluetoothConnectionStatus.disconnected;
  final List<SensorDevice> _availableDevices = [];
  SensorDevice? _connectedDevice;
  SensorData? _latestData;
  String _errorMessage = '';

  // เพิ่มตัวแปรเหล่านี้ - Plant connection info
  String? connectedPlantId;
  String? connectedPlantName;

  // BLE objects
  BluetoothDevice? _bleDevice;
  BluetoothCharacteristic? _characteristic;
  StreamSubscription? _dataSubscription;
  StreamSubscription? _scanSubscription;

  // Getters
  BluetoothConnectionStatus get status => _status;
  List<SensorDevice> get availableDevices =>
      List.unmodifiable(_availableDevices);
  SensorDevice? get connectedDevice => _connectedDevice;
  SensorData? get latestData => _latestData;
  String get errorMessage => _errorMessage;

  bool get isConnected => _status == BluetoothConnectionStatus.connected;
  bool get isScanning => _status == BluetoothConnectionStatus.scanning;
  bool get isConnecting => _status == BluetoothConnectionStatus.connecting;

  // เพิ่ม method นี้ - Set connected plant info
  void setConnectedPlant(String plantId, String plantName) {
    connectedPlantId = plantId;
    connectedPlantName = plantName;
    notifyListeners();
  }

  void clearAvailableDevices() {
    _availableDevices.clear();
    notifyListeners();
  }

  // Initialize Bluetooth
  Future<bool> initialize() async {
    try {
      if (!await FlutterBluePlus.isSupported) {
        _setError('Bluetooth not supported');
        return false;
      }

      // Listen to adapter state
      FlutterBluePlus.adapterState.listen((state) {
        if (state == BluetoothAdapterState.off) {
          _setError('Please turn on Bluetooth');
        } else if (state == BluetoothAdapterState.on) {
          _clearError();
        }
      });

      // Check current state
      final currentState = await FlutterBluePlus.adapterState.first;
      if (currentState != BluetoothAdapterState.on) {
        _setError('Bluetooth is not enabled');
        return false;
      }

      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to initialize Bluetooth: $e');
      return false;
    }
  }

  // Scan for devices
  Future<void> startScan() async {
    if (_status == BluetoothConnectionStatus.scanning) return;

    _setStatus(BluetoothConnectionStatus.scanning);
    clearAvailableDevices(); // ใช้ method ใหม่แทน
    _clearError();

    try {
      // Cancel previous subscription
      await _scanSubscription?.cancel();

      // Start scanning
      await FlutterBluePlus.startScan(timeout: scanTimeout);

      // Listen to results
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (final result in results) {
          if (result.device.platformName.isNotEmpty) {
            _addDeviceIfNew(SensorDevice.fromScanResult(result));
          }
        }
      });

      // Auto-stop after timeout
      Timer(scanTimeout, () async {
        await stopScan();
      });
    } catch (e) {
      _setError('การสแกนล้มเหลว: $e');
      _setStatus(BluetoothConnectionStatus.disconnected);
    }
  }

  // Stop scanning
  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
      await _scanSubscription?.cancel();
      _scanSubscription = null;

      if (_status == BluetoothConnectionStatus.scanning) {
        _setStatus(BluetoothConnectionStatus.disconnected);
      }
    } catch (e) {
      debugPrint('Error stopping scan: $e');
    }
  }

  // Connect to device
  Future<bool> connectToDevice(SensorDevice device) async {
    if (_status == BluetoothConnectionStatus.connecting) return false;

    _setStatus(BluetoothConnectionStatus.connecting);
    _clearError();

    try {
      // Connect to device
      await device.device.connect(timeout: connectTimeout);
      _bleDevice = device.device;

      // Discover services
      final services = await device.device.discoverServices();
      final targetService = services.firstWhere(
        (s) => s.uuid.toString().toLowerCase() == serviceUuid.toLowerCase(),
        orElse: () => throw Exception('Service not found'),
      );

      // Find characteristic
      _characteristic = targetService.characteristics.firstWhere(
        (c) =>
            c.uuid.toString().toLowerCase() == characteristicUuid.toLowerCase(),
        orElse: () => throw Exception('Characteristic not found'),
      );

      // Enable notifications
      await _characteristic!.setNotifyValue(true);
      // ในส่วน _dataSubscription = _characteristic!.lastValueStream.listen
      _dataSubscription = _characteristic!.lastValueStream.listen((value) {
        if (value.isNotEmpty) {
          final data = utf8.decode(value);
          debugPrint('Raw BLE data received: $data'); // เพิ่มบรรทัดนี้
          _latestData = SensorData.fromString(data);
          debugPrint('Parsed sensor data: $_latestData'); // เพิ่มบรรทัดนี้
          notifyListeners();
        }
      });

      _connectedDevice = device;
      _setStatus(BluetoothConnectionStatus.connected);
      return true;
    } catch (e) {
      _setError('Connection failed: $e');
      _setStatus(BluetoothConnectionStatus.error);

      // Auto-reset to disconnected
      Timer(const Duration(seconds: 3), () {
        if (_status == BluetoothConnectionStatus.error) {
          _setStatus(BluetoothConnectionStatus.disconnected);
        }
      });

      await _cleanup();
      return false;
    }
  }

  // Enhanced disconnect method - ตัดการเชื่อมต่อและล้างข้อมูล plant
  Future<void> disconnect() async {
    try {
      await _bleDevice?.disconnect();
    } catch (e) {
      debugPrint('Error disconnecting: $e');
    } finally {
      await _cleanup();
      _setStatus(BluetoothConnectionStatus.disconnected);
      _connectedDevice = null;
      _latestData = null;

      // ล้างข้อมูล plant ที่เชื่อมต่อ
      connectedPlantId = null;
      connectedPlantName = null;

      _clearError();
    }
  }

  // Helper methods
  void _addDeviceIfNew(SensorDevice device) {
    final exists = _availableDevices.any((d) => d.address == device.address);
    if (!exists) {
      _availableDevices.add(device);
      notifyListeners();
    }
  }

  void _setStatus(BluetoothConnectionStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      notifyListeners();
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage.isNotEmpty) {
      _errorMessage = '';
      notifyListeners();
    }
  }

  Future<void> _cleanup() async {
    await _dataSubscription?.cancel();
    await _scanSubscription?.cancel();
    _dataSubscription = null;
    _scanSubscription = null;
    _bleDevice = null;
    _characteristic = null;
  }

  void clearError() => _clearError();

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }
}
