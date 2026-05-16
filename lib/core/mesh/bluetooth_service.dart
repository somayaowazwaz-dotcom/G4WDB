class BluetoothService {
  static Future<bool> isBluetoothEnabled() async {
    return false;
  }

  static Future<bool> enableBluetooth() async {
    return false;
  }

  static Stream<dynamic> startDiscovery() {
    return const Stream.empty();
  }

  static Future<void> stopDiscovery() async {
    return;
  }
}
