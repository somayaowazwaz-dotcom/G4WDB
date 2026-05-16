import 'database_helper.dart';

class UXODatabase {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<Map<String, dynamic>> getUXOInfo(String query) async {
    final db = await _dbHelper.getDatabaseByName('uxo.sqlite');
    final results = await db.query(
      'uxo_info',
      where: 'name = ?',
      whereArgs: [query],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : <String, dynamic>{};
  }
}
