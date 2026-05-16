import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database_helper.dart';
import '../../models/mesh_message.dart';

class FamilySearchAgent extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Simple Bloom Filter replacement (memory-safe + offline)
  final Set<String> _bloomSet = <String>{};

  final List<Map<String, dynamic>> _matches = [];

  List<Map<String, dynamic>> get matches => _matches;

  Future<void> addPersonToSearch({
    required String name,
    required String description,
  }) async {
    final hash = _createPrivacyHash(name, description);

    // Bloom filter simulation (fast O(1) lookup)
    _bloomSet.add(hash);

    await _dbHelper.database.then((db) {
      db.insert('family_search_queue', {
        'hash': hash,
        'description': description,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    });

    notifyListeners();
  }

  Future<void> checkForMatches(MeshMessage message) async {
    if (message.type != MessageType.familySearch) return;

    final hash = message.data['hashed_id'];

    // Bloom filter check (safe approximation)
    if (_bloomSet.contains(hash)) {
      _matches.add({
        'hash': hash,
        'found_at': DateTime.now(),
        'confidence': 'Potential match',
      });

      notifyListeners();
    }
  }

  String _createPrivacyHash(String name, String description) {
    // Simple deterministic hash (replace with SHA256 later if needed)
    return '${name}_$description'.hashCode.toString();
  }
}

final familySearchAgentProvider = ChangeNotifierProvider((ref) {
  return FamilySearchAgent();
});
