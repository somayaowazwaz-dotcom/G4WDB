class AppConstants {
  static const String appName = "G4WDB AI Agent";
  static const String appVersion = "1.0.0";
  
  // Database Names
  static const String dbTCCC = "tccc.sqlite";
  static const String dbUXO = "uxo.sqlite";
  
  // Mesh Network
  static const String meshServiceId = "g4wdb_mesh_service";
  static const int meshMaxHopCount = 5;
  static const int messageTTLSeconds = 21600; // 6 hours
  
  // UI Colors
  static const int colorMedical = 0xFFE53935; // Red
  static const int colorUXO = 0xFFFF9800;     // Orange
  static const int colorMesh = 0xFF2196F3;    // Blue
  static const int colorFamily = 0xFF9C27B0;  // Purple
  static const int colorSilent = 0xFF009688;  // Teal
}