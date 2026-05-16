import 'database_helper.dart';

class TCCCDatabase {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  
  Future<List<Map<String, dynamic>>> getTriageGuidelines() async {
    final db = await _dbHelper.getDatabaseByName('tccc.sqlite');
    return await db.query('tccc_guidelines');
  }
  
  Future<Map<String, dynamic>?> getWoundAssessment(String woundType) async {
    final db = await _dbHelper.getDatabaseByName('tccc.sqlite');
    final results = await db.query(
      'wound_assessments',
      where: 'wound_type = ?',
      whereArgs: [woundType],
    );
    return results.isNotEmpty ? results.first : null;
  }
  
  Future<Map<String, dynamic>?> getTourniquetProtocol() async {
    final db = await _dbHelper.getDatabaseByName('tccc.sqlite');
    final results = await db.query(
      'tourniquet_protocols',
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }
  
  Future<List<Map<String, dynamic>>> getInjuryTreatments({
    required String injuryType,
    required String severity,
  }) async {
    final db = await _dbHelper.getDatabaseByName('tccc.sqlite');
    return await db.query(
      'injury_treatments',
      where: 'injury_type = ? AND severity = ?',
      whereArgs: [injuryType, severity],
    );
  }
}
