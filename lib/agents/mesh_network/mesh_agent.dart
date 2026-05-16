import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nearby_connections/nearby_connections.dart';
import '../../models/mesh_message.dart';

class MeshNetworkAgent extends ChangeNotifier {
  final Nearby _nearby = Nearby();
  final Set<String> _messageHashes = <String>{};
  
  bool _isConnected = false;
  final List<String> _connectedDevices = [];
  bool _isDiscovering = false;
  bool _simulationMode = false;
  int _deliveryRate = 0;
  int _totalMessages = 0;
  int _successfulDeliveries = 0;
  
  bool get isConnected => _isConnected;
  bool get isDiscovering => _simulationMode || _isDiscovering;
  List<String> get connectedDevices => _connectedDevices;
  int get deliveryRate => _deliveryRate;
  
  Future<void> initialize() async {
    if (kIsWeb || (defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS)) {
      debugPrint('ℹ️ Simulating Mesh Network for Development');
      _simulationMode = true;
      notifyListeners();
      return;
    }

    await _startAdvertising();
    await _startDiscovery();
    notifyListeners();
  }

  Future<void> stop() async {
    _simulationMode = false;
    if (_isDiscovering) {
      await _nearby.stopDiscovery();
      _isDiscovering = false;
    }
    await _nearby.stopAdvertising();
    await _nearby.stopAllEndpoints();
    _connectedDevices.clear();
    _isConnected = false;
    notifyListeners();
  }
  
  Future<void> _startAdvertising() async {
    const strategy = Strategy.P2P_CLUSTER;
    
    await _nearby.startAdvertising(
      'G4WDB_Device',
      strategy,
      onConnectionInitiated: (endpointId, info) async {
        debugPrint('Connection initiated with $endpointId');
        await _nearby.acceptConnection(
          endpointId,
          onPayLoadRecieved: (endpointId, payload) {},
        );
      },
      onConnectionResult: (endpointId, result) {
        if (result == Status.CONNECTED) {
          if (!_connectedDevices.contains(endpointId)) {
            _connectedDevices.add(endpointId);
          }
          _isConnected = true;
          notifyListeners();
        }
      },
      onDisconnected: (endpointId) {
        _connectedDevices.remove(endpointId);
        if (_connectedDevices.isEmpty) {
          _isConnected = false;
        }
        notifyListeners();
      },
    );
  }
  
  Future<void> _startDiscovery() async {
    const strategy = Strategy.P2P_CLUSTER;
    _isDiscovering = true;

    final started = await _nearby.startDiscovery(
      'G4WDB',
      strategy,
      onEndpointFound: (endpointId, deviceName, serviceId) {
        debugPrint('Device found: $deviceName ($endpointId)');
        _connectToDevice(endpointId);
      },
      onEndpointLost: (endpointId) {
        debugPrint('Device lost: $endpointId');
      },
    );

    if (!started) {
      debugPrint('⚠️ Unable to start Nearby Connections discovery');
    }
  }
  
  Future<void> _connectToDevice(String endpointId) async {
    try {
      await _nearby.requestConnection(
        'G4WDB_User',
        endpointId,
        onConnectionInitiated: (endpointId, info) async {
          await _nearby.acceptConnection(
            endpointId,
            onPayLoadRecieved: (endpointId, payload) {},
          );
        },
        onConnectionResult: (endpointId, result) {
          if (result == Status.CONNECTED) {
            if (!_connectedDevices.contains(endpointId)) {
              _connectedDevices.add(endpointId);
            }
            _isConnected = true;
            notifyListeners();
          }
        },
        onDisconnected: (endpointId) {
          _connectedDevices.remove(endpointId);
          if (_connectedDevices.isEmpty) {
            _isConnected = false;
          }
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint('Connection error: $e');
    }
  }
  
  Future<void> sendMessage(MeshMessage message) async {
    final hashedData = _hashMessage(message);
    if (!_messageHashes.add(hashedData)) {
      debugPrint('Message already sent, skipping duplicate delivery');
      return;
    }

    _totalMessages++;
    
    for (final deviceId in _connectedDevices) {
      try {
        final payload = Uint8List.fromList(
          utf8.encode(jsonEncode(message.toJson())),
        );
        await _nearby.sendBytesPayload(deviceId, payload);
        _successfulDeliveries++;
        _updateDeliveryRate();
      } catch (e) {
        debugPrint('Send failed to $deviceId: $e');
      }
    }
    
    notifyListeners();
  }
  
  void _updateDeliveryRate() {
    if (_totalMessages > 0) {
      _deliveryRate = ((_successfulDeliveries / _totalMessages) * 100).round();
    }
  }
  
  String _hashMessage(MeshMessage message) {
    // Create privacy-preserving hash
    return '${message.type}:${message.timestamp.millisecondsSinceEpoch}';
  }
  
  Future<void> broadcastDangerZone({
    required double latitude,
    required double longitude,
    required double radius,
    required String uxotype,
  }) async {
    final message = MeshMessage(
      type: MessageType.dangerZone,
      data: {
        'lat': latitude,
        'lng': longitude,
        'radius': radius,
        'uxo_type': uxotype,
        'timestamp': DateTime.now().toIso8601String(),
      },
      ttl: const Duration(hours: 6),
    );
    
    await sendMessage(message);
  }
  
  Future<void> broadcastFamilySearch({
    required String hashedId,
    required String location,
  }) async {
    final message = MeshMessage(
      type: MessageType.familySearch,
      data: {
        'hashed_id': hashedId,
        'location': location,
        'timestamp': DateTime.now().toIso8601String(),
      },
      ttl: const Duration(hours: 24),
    );
    
    await sendMessage(message);
  }
  
  @override
  void dispose() {
    if (_isDiscovering) {
      _nearby.stopDiscovery();
    }
    _nearby.stopAllEndpoints();
    super.dispose();
  }
}

final meshNetworkAgentProvider = ChangeNotifierProvider((ref) {
  return MeshNetworkAgent();
});