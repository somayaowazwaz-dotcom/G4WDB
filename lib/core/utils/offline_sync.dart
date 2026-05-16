import 'package:connectivity_plus/connectivity_plus.dart';

class OfflineSync {
  static Future<bool> isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result == ConnectivityResult.wifi || 
           result == ConnectivityResult.mobile;
  }

  static Stream<ConnectivityResult> connectionStream() {
    return Connectivity().onConnectivityChanged;
  }
}