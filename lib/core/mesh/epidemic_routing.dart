import 'dart:async';
import '../../models/mesh_message.dart';

class EpidemicRouting {
  // Keep track of seen message IDs to prevent loops
  final Set<String> _seenMessages = {};
  
  Future<bool> shouldForward(MeshMessage message) async {
    if (_seenMessages.contains(message.id)) {
      return false; // Already processed
    }
    _seenMessages.add(message.id);
    
    // Check TTL
    if (DateTime.now().isAfter(message.timestamp.add(message.ttl))) {
      return false; // Expired
    }
    
    return true;
  }

  void clearCache() {
    _seenMessages.clear();
  }
}