import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'app.dart';
import 'core/database/database_helper.dart';
import 'core/gemma_engine/gemma_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize sqflite for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  // Initialize localization
  await EasyLocalization.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize databases
  await initializeDatabases();
  
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
        Locale('uk'),
        Locale('fr'),
        Locale('de'),
        Locale('ru'),
        Locale('fa'),
        Locale('ur'),
        Locale('bn'),
        Locale('hi'),
        Locale('ks'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const ProviderScope(
        child: G4WDBApp(),
      ),
    ),
  );
}

Future<void> initializeDatabases() async {
  // Use getDatabasesPath() which is consistent with DatabaseHelper
  final dbPath = await getDatabasesPath();
  
  // Ensure the directory exists
  final dbDir = Directory(dbPath);
  if (!await dbDir.exists()) {
    await dbDir.create(recursive: true);
  }
  
  // Copy bundled databases to the system databases directory
  await DatabaseHelper.copyBundledDatabase('tccc.sqlite', dbPath);
  await DatabaseHelper.copyBundledDatabase('uxo.sqlite', dbPath);
}
