import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'config/routes.dart';
import 'config/themes.dart';
import 'core/utils/battery_optimizer.dart';
import 'features/accessibility/accessibility_service.dart';

class G4WDBApp extends ConsumerStatefulWidget {
  const G4WDBApp({super.key});

  @override
  ConsumerState<G4WDBApp> createState() => _G4WDBAppState();
}

class _G4WDBAppState extends ConsumerState<G4WDBApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize battery optimization
    await BatteryOptimizer.instance.initialize();
    
    // Initialize accessibility services
    await AccessibilityService.instance.initialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      // Save state when app goes to background
      BatteryOptimizer.instance.saveState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accessibilityService = ref.watch(accessibilityServiceProvider);

    return MaterialApp(
      title: 'G4WDB AI Agent',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      
      // Responsive theme
      theme: accessibilityService.highContrast ? AppThemes.highContrastLightTheme : AppThemes.lightTheme,
      darkTheme: accessibilityService.highContrast ? AppThemes.highContrastDarkTheme : AppThemes.darkTheme,
      themeMode: ThemeMode.dark, // Default to dark for battery saving
      
      // Routes
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
      
      // Accessibility
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: accessibilityService.textScaler,
          ),
          child: child!,
        );
      },
    );
  }
}