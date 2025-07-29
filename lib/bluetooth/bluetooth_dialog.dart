import 'package:flutter/material.dart';
import 'bluetooth_manager.dart';

class BluetoothDialog extends StatefulWidget {
  const BluetoothDialog({super.key});

  @override
  State<BluetoothDialog> createState() => _BluetoothDialogState();

  // Static method to show dialog
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const BluetoothDialog(),
    );
  }
}

class _BluetoothDialogState extends State<BluetoothDialog> {
  final BluetoothManager _bluetoothManager = BluetoothManager();
  bool _isInitialized = false;
  BluetoothConnectionStatus? _lastNotifiedStatus;

  @override
  void initState() {
    super.initState();
    _bluetoothManager.addListener(_onBluetoothStateChanged);
    _initializeManager();
  }

  @override
  void dispose() {
    _bluetoothManager.removeListener(_onBluetoothStateChanged);
    super.dispose();
  }

  Future<void> _initializeManager() async {
    if (!_isInitialized) {
      final success = await _bluetoothManager.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = success;
        });
        if (!success) {
          _showMessage(_bluetoothManager.errorMessage, MessageType.error);
        }
      }
    }
  }

  void _onBluetoothStateChanged() {
    if (mounted) {
      setState(() {});

      // Show connection status messages only once per status change
      final currentStatus = _bluetoothManager.status;

      if (currentStatus != _lastNotifiedStatus) {
        if (currentStatus == BluetoothConnectionStatus.connected) {
          _showMessage(
            'เชื่อมต่อกับ ${_bluetoothManager.connectedDevice?.name} สำเร็จ!',
            MessageType.success,
          );
        } else if (currentStatus == BluetoothConnectionStatus.error) {
          _showMessage(_bluetoothManager.errorMessage, MessageType.error);
        }

        _lastNotifiedStatus = currentStatus;
      }
    }
  }

  void _showMessage(String message, MessageType type) {
    if (mounted && message.isNotEmpty) {
      final color = switch (type) {
        MessageType.success => Colors.green,
        MessageType.error => Colors.red,
        MessageType.info => Colors.blue,
        MessageType.warning => Colors.orange,
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _startScan() async {
    _showMessage('กำลังค้นหาเซ็นเซอร์...', MessageType.info);
    await _bluetoothManager.startScan();

    if (mounted) {
      final deviceCount = _bluetoothManager.availableDevices.length;
      _showMessage(
        'พบเซ็นเซอร์ $deviceCount เครื่อง',
        deviceCount > 0 ? MessageType.success : MessageType.warning,
      );
    }
  }

  Future<void> _connectToDevice(SensorDevice device) async {
    // Reset notification status when starting new connection
    _lastNotifiedStatus = null;
    final success = await _bluetoothManager.connectToDevice(device);
    if (!success && mounted) {
      _showMessage(
        'ไม่สามารถเชื่อมต่อกับ ${device.name} ได้',
        MessageType.error,
      );
    }
  }

  Future<void> _disconnect() async {
    // Reset notification status when disconnecting
    _lastNotifiedStatus = null;
    await _bluetoothManager.disconnect();
    if (mounted) {
      _showMessage('ตัดการเชื่อมต่อสำเร็จ', MessageType.warning);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: _buildTitle(),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.5,
        child: !_isInitialized ? _buildLoadingView() : _buildMainContent(),
      ),
      actions: _buildActions(),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Icon(
          Icons.bluetooth,
          color: _bluetoothManager.isConnected ? Colors.blue : Colors.grey,
          size: 24,
        ),
        const SizedBox(width: 8),
        const Text(
          'จัดการเซ็นเซอร์',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        if (_bluetoothManager.isScanning || _bluetoothManager.isConnecting)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('กำลังเริ่มต้น Bluetooth...'),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatusCard(),
        const SizedBox(height: 16),
        _buildErrorMessage(),
        _buildDeviceListHeader(),
        const SizedBox(height: 8),
        Expanded(child: _buildDeviceList()),
      ],
    );
  }

  Widget _buildStatusCard() {
    final status = _getConnectionStatus();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        border: Border.all(color: status.color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(status.icon, color: status.color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.title,
                  style: TextStyle(
                    color: status.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (status.subtitle != null)
                  Text(
                    status.subtitle!,
                    style: TextStyle(
                      color: status.color.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          // Show sensor data if connected
          if (_bluetoothManager.isConnected &&
              _bluetoothManager.latestData != null)
            _buildSensorDataChip(),
        ],
      ),
    );
  }

  Widget _buildSensorDataChip() {
    final data = _bluetoothManager.latestData!;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.water_drop, size: 14, color: Colors.blue),
              Text(
                '${data.soilMoisture}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.thermostat, size: 14, color: Colors.red),
              Text(
                '${data.temperature}°C',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    if (_bluetoothManager.errorMessage.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        border: Border.all(color: Colors.red.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _bluetoothManager.errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
          IconButton(
            onPressed: _bluetoothManager.clearError,
            icon: const Icon(Icons.close, size: 16),
            constraints: const BoxConstraints.tightFor(width: 24, height: 24),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceListHeader() {
    final deviceCount = _bluetoothManager.availableDevices.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'เซ็นเซอร์ที่พบ:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            if (_bluetoothManager.isScanning)
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color:
                    deviceCount > 0
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: deviceCount > 0 ? Colors.green : Colors.grey,
                  width: 1,
                ),
              ),
              child: Text(
                '$deviceCount เครื่อง',
                style: TextStyle(
                  fontSize: 12,
                  color: deviceCount > 0 ? Colors.green : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeviceList() {
    if (_bluetoothManager.availableDevices.isEmpty) {
      return _buildEmptyDeviceList();
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _bluetoothManager.availableDevices.length,
      itemBuilder: (context, index) {
        final device = _bluetoothManager.availableDevices[index];
        return _buildDeviceCard(device);
      },
    );
  }

  Widget _buildEmptyDeviceList() {
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
            'กดปุ่ม "สแกน" เพื่อค้นหาเซ็นเซอร์',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(SensorDevice device) {
    final isConnected =
        _bluetoothManager.connectedDevice?.address == device.address;
    final isConnecting = _bluetoothManager.isConnecting;

    return Card(
      elevation: isConnected ? 4 : 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: isConnected ? Colors.blue.withOpacity(0.05) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              isConnected ? Colors.blue.withOpacity(0.3) : Colors.transparent,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                isConnected
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.sensors,
            color: isConnected ? Colors.blue : Colors.grey,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                device.name,
                style: TextStyle(
                  fontWeight: isConnected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(
              device.signalIcon,
              size: 16,
              color: _getSignalColor(device.signalStrength),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${device.signalStrength} dBm',
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: SizedBox(
          width: 80,
          height: 32,
          child: ElevatedButton(
            onPressed:
                (isConnecting && !isConnected)
                    ? null
                    : () async {
                      if (isConnected) {
                        await _disconnect();
                      } else {
                        await _connectToDevice(device);
                      }
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor: isConnected ? Colors.red : Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: isConnected ? 2 : 1,
            ),
            child:
                (isConnecting && !isConnected)
                    ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                    : Text(
                      isConnected ? 'ตัดการเชื่อมต่อ' : 'เชื่อมต่อ',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('ปิด'),
      ),
      ElevatedButton.icon(
        onPressed: _bluetoothManager.isScanning ? null : _startScan,
        icon:
            _bluetoothManager.isScanning
                ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Icon(Icons.refresh, size: 16),
        label: Text(_bluetoothManager.isScanning ? 'กำลังสแกน...' : 'สแกน'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ];
  }

  // Helper methods
  ConnectionStatusInfo _getConnectionStatus() {
    switch (_bluetoothManager.status) {
      case BluetoothConnectionStatus.connected:
        return ConnectionStatusInfo(
          color: Colors.green,
          icon: Icons.check_circle,
          title: 'เชื่อมต่อแล้ว',
          subtitle: _bluetoothManager.connectedDevice?.name,
        );
      case BluetoothConnectionStatus.connecting:
        return ConnectionStatusInfo(
          color: Colors.blue,
          icon: Icons.bluetooth_searching,
          title: 'กำลังเชื่อมต่อ...',
          subtitle: null,
        );
      case BluetoothConnectionStatus.scanning:
        return ConnectionStatusInfo(
          color: Colors.orange,
          icon: Icons.search,
          title: 'กำลังค้นหาเซ็นเซอร์...',
          subtitle: null,
        );
      case BluetoothConnectionStatus.error:
        return ConnectionStatusInfo(
          color: Colors.red,
          icon: Icons.error,
          title: 'เกิดข้อผิดพลาด',
          subtitle: null,
        );
      default:
        return ConnectionStatusInfo(
          color: Colors.grey,
          icon: Icons.bluetooth_disabled,
          title: 'ไม่ได้เชื่อมต่อ',
          subtitle: 'เลือกเซ็นเซอร์เพื่อเชื่อมต่อ',
        );
    }
  }

  Color _getSignalColor(int strength) {
    if (strength > -40) return Colors.green;
    if (strength > -55) return Colors.orange;
    return Colors.red;
  }
}

// Helper classes
class ConnectionStatusInfo {
  final Color color;
  final IconData icon;
  final String title;
  final String? subtitle;

  ConnectionStatusInfo({
    required this.color,
    required this.icon,
    required this.title,
    this.subtitle,
  });
}

enum MessageType { success, error, info, warning }
