import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static final Map<String, Database> _databases = {};
  
  DatabaseHelper._init();
  
  Future<Database> get database async {
    return await getDatabaseByName('g4wdb.db');
  }

  Future<Database> getDatabaseByName(String dbName) async {
    if (_databases.containsKey(dbName)) return _databases[dbName]!;
    
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);
    
    _databases[dbName] = await openDatabase(
      path,
      version: 1,
      onCreate: dbName == 'g4wdb.db' ? _createDB : null,
    );
    return _databases[dbName]!;
  }
  
  Future<void> _createDB(Database db, int version) async {
    // Create tables for offline sync
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        data TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');
    
    await db.execute('''
      CREATE TABLE user_preferences (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }
  
  static Future<void> copyBundledDatabase(String dbName, String targetPath) async {
    final dbPath = join(targetPath, dbName);
    final file = File(dbPath);
    
    // If the file already exists and is not empty, we don't need to copy it
    if (await file.exists() && await file.length() > 0) return;
    
    try {
      final byteData = await rootBundle.load('assets/databases/$dbName');
      if (byteData.lengthInBytes == 0) {
        print('⚠️ Warning: bundled database $dbName is empty.');
        return;
      }
      
      final buffer = byteData.buffer.asUint8List();
      await file.writeAsBytes(buffer, flush: true);
      print('✅ Database $dbName copied to $dbPath');
    } catch (e) {
      print('ℹ️ Note: Database $dbName not found in assets or could not be copied. It will be initialized on-demand.');
    }
  }
  
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}