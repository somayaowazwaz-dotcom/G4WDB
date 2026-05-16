import 'package:flutter/material.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/splash_screen.dart';
import '../ui/screens/settings_screen.dart';
import '../ui/screens/medical_triage_screen.dart';
import '../ui/screens/uxo_recognition_screen.dart';
import '../ui/screens/mesh_network_screen.dart';
import '../ui/screens/family_search_screen.dart';
import '../ui/screens/chat_screen.dart';
import '../ui/screens/survival_tracker_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String settings = '/settings';
  static const String medicalTriage = '/medical-triage';
  static const String uxoRecognition = '/uxo-recognition';
  static const String meshNetwork = '/mesh-network';
  static const String familySearch = '/family-search';
  static const String survivalTracker = '/survival-tracker';
  static const String chat = '/chat';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case medicalTriage:
        return MaterialPageRoute(builder: (_) => const MedicalTriageScreen());
      case uxoRecognition:
        return MaterialPageRoute(builder: (_) => const UXORecognitionScreen());
      case meshNetwork:
        return MaterialPageRoute(builder: (_) => const MeshNetworkScreen());
      case familySearch:
        return MaterialPageRoute(builder: (_) => const FamilySearchScreen());
      case survivalTracker:
        return MaterialPageRoute(builder: (_) => const SurvivalTrackerScreen());
      case chat:
        return MaterialPageRoute(builder: (_) => const ChatScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
