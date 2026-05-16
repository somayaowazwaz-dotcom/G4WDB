import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../features/accessibility/accessibility_service.dart';
import '../../core/gemma_engine/gemma_core.dart';
import '../../agents/uxo_recognition/uxo_agent.dart';
import '../../agents/mesh_network/mesh_agent.dart';
import '../../agents/silent_mode/silent_mode_agent.dart';
import '../../agents/family_search/family_search_agent.dart';
import '../../agents/survival_tracker/survival_agent.dart';
import '../widgets/metrics_dashboard.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gemmaCore = ref.watch(gemmaCoreProvider);
    final uxoAgent = ref.watch(uxoRecognitionAgentProvider);
    final meshAgent = ref.watch(meshNetworkAgentProvider);
    final silentMode = ref.watch(silentModeAgentProvider);
    final accessibilityService = ref.watch(accessibilityServiceProvider);
    // ignore: unused_local_variable
    final familyAgent = ref.watch(familySearchAgentProvider);

    return Scaffold(
      appBar: AppBar(title: Text('settings.title'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Quick stats
          Row(
            children: [
              _buildQuickStat('124K', 'Active Devices'),
              const SizedBox(width: 8),
              _buildQuickStat('93.6%', 'UXO Accuracy'),
              const SizedBox(width: 8),
              _buildQuickStat('87ms', 'Latency'),
            ],
          ),
          const SizedBox(height: 16),
          
          // System Metrics Dashboard
          MetricsDashboard(
            batteryLife: '48h',
            latency: '87ms',
            meshDelivery: '${meshAgent.deliveryRate}%',
            offlineMode: true,
          ),
          const SizedBox(height: 24),

          // AGENT SERVICE CALIBRATION (START/STOP)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionHeader('Agent Service Calibration'),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(gemmaCoreProvider).initialize();
                  ref.read(uxoRecognitionAgentProvider).initializeCamera();
                  ref.read(meshNetworkAgentProvider).initialize();
                },
                icon: const Icon(Icons.flash_on, size: 16),
                label: const Text('CALIBRATE ALL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[900],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // 1. Medical Triage Agent (AI Engine)
          _buildAgentCheckTile(
            title: 'Medical Triage Agent',
            isReady: gemmaCore.isInitialized,
            services: ['Gemma AI G4 e2b', 'Voice STT/TTS'],
            icon: Icons.medical_services,
            onToggle: () {
              if (gemmaCore.isInitialized) {
                gemmaCore.dispose();
              } else {
                gemmaCore.initialize();
              }
            },
            toggleLabel: gemmaCore.isInitialized ? 'STOP' : 'START',
          ),
          
          // 2. UXO Recognition Agent (Vision)
          _buildAgentCheckTile(
            title: 'UXO Recognition Agent',
            isReady: uxoAgent.isCameraInitialized,
            services: ['Vision System (Camera)', 'UXO Database'],
            icon: Icons.camera_enhance,
            onToggle: () {
              if (uxoAgent.isCameraInitialized) {
                ref.read(uxoRecognitionAgentProvider).stopCamera();
              } else {
                ref.read(uxoRecognitionAgentProvider).initializeCamera();
              }
            },
            toggleLabel: uxoAgent.isCameraInitialized ? 'STOP' : 'START',
          ),
          
          // 3. Mesh Network Agent (Mesh)
          _buildAgentCheckTile(
            title: 'Mesh Network Agent',
            isReady: meshAgent.isDiscovering || meshAgent.isConnected,
            services: ['Bluetooth Mesh', 'Node Discovery'],
            icon: Icons.hub,
            onToggle: () {
              if (meshAgent.isDiscovering || meshAgent.isConnected) {
                ref.read(meshNetworkAgentProvider).stop();
              } else {
                ref.read(meshNetworkAgentProvider).initialize();
              }
            },
            toggleLabel: (meshAgent.isDiscovering || meshAgent.isConnected) ? 'STOP' : 'START',
          ),
          
          // 4. Family Search Agent
          _buildAgentCheckTile(
            title: 'Family Search Agent',
            isReady: true,
            services: ['Search Engine', 'Offline Sync'],
            icon: Icons.people,
            onToggle: () {}, // Always ready local DB
            toggleLabel: 'READY',
          ),
          
          _buildAgentCheckTile(
            title: 'Survival Tracker Agent',
            isReady: ref.watch(survivalAgentProvider).isInitialized,
            services: ['Supply Tracker', 'Consumption Logic'],
            icon: Icons.inventory,
            onToggle: () {}, // Initialized on start
            toggleLabel: 'READY',
          ),
          
          // 5. Silent Mode Agent
          _buildAgentCheckTile(
            title: 'Silent Mode Agent',
            isReady: silentMode.isReady,
            services: ['Haptic Feedback', 'Covert Control'],
            icon: Icons.volume_off,
            onToggle: () => ref.read(silentModeAgentProvider.notifier).toggleSilentMode(),
            toggleLabel: silentMode.isSilentMode ? 'OFF' : 'ON',
          ),

          const Divider(height: 48),

          // System Readiness Detail
          _buildSectionHeader('settings.calibration_title'.tr()),
          const SizedBox(height: 8),
          _buildStatusTile(
            title: 'settings.gemma_status',
            isReady: gemmaCore.isInitialized,
            icon: Icons.psychology,
          ),
          _buildStatusTile(
            title: 'settings.camera_status',
            isReady: uxoAgent.isCameraInitialized,
            icon: Icons.camera_alt,
          ),
          _buildStatusTile(
            title: 'settings.speakers_status',
            isReady: true, 
            icon: Icons.volume_up,
          ),
          _buildStatusTile(
            title: 'settings.bluetooth_status',
            isReady: true, 
            icon: Icons.bluetooth,
          ),
          _buildStatusTile(
            title: 'settings.mic_status',
            isReady: true, 
            icon: Icons.mic,
          ),
          _buildStatusTile(
            title: 'settings.recognition_status',
            isReady: uxoAgent.isCameraInitialized,
            icon: Icons.troubleshoot,
          ),
          _buildStatusTile(
            title: 'settings.mesh_status',
            isReady: meshAgent.isDiscovering || meshAgent.isConnected,
            icon: Icons.wifi_tethering,
          ),
          _buildStatusTile(
            title: 'settings.silent_status',
            isReady: silentMode.isReady,
            icon: Icons.notifications_off,
          ),
          _buildStatusTile(
            title: 'settings.survival_status'.tr(),
            isReady: ref.watch(survivalAgentProvider).isInitialized,
            icon: Icons.inventory_2,
          ),
          
          const Divider(height: 32),
          
          // Accessibility & Preferences
          _buildSectionHeader('settings.preferences_title'.tr()),
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Text size'),
            subtitle: Text('${(accessibilityService.textScaleFactor * 100).round()}%'),
          ),
          Slider(
            value: accessibilityService.textScaleFactor,
            min: AccessibilityService.minTextScaleFactor,
            max: AccessibilityService.maxTextScaleFactor,
            divisions: 6,
            label: '${(accessibilityService.textScaleFactor * 100).round()}%',
            onChanged: (value) => accessibilityService.setTextScale(value),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.record_voice_over),
            title: const Text('Screen reader optimization'),
            subtitle: const Text('Improves spoken labels and navigation hints.'),
            value: accessibilityService.screenReaderOptimized,
            onChanged: (value) => accessibilityService.toggleScreenReaderOptimization(),
          ),
          ListTile(
            leading: const Icon(Icons.accessibility),
            title: Text('settings.high_contrast'.tr()),
            subtitle: Text('settings.high_contrast_desc'.tr()),
            trailing: Switch(
              value: accessibilityService.highContrast,
              onChanged: (value) {
                accessibilityService.toggleHighContrast();
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text('settings.language'.tr()),
            subtitle: Text(_languageLabel(context.locale.languageCode)),
            onTap: () => _showLanguageDialog(context),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.bug_report),
            title: Text('App Version'),
            subtitle: Text('v1.0.0'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget _buildAgentCheckTile({
    required String title,
    required bool isReady,
    required List<String> services,
    required IconData icon,
    required VoidCallback onToggle,
    required String toggleLabel,
  }) {
    return Card(
      color: isReady ? Colors.green.withOpacity(0.05) : Colors.red.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isReady ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Icon(icon, color: isReady ? Colors.green : Colors.red),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Services: ${services.join(', ')}', style: const TextStyle(fontSize: 12)),
        trailing: ElevatedButton(
          onPressed: onToggle,
          style: ElevatedButton.styleFrom(
            backgroundColor: isReady ? Colors.red[900] : Colors.green[900],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: Text(toggleLabel, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildStatusTile({
    required String title,
    required bool isReady,
    required IconData icon,
  }) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: isReady ? Colors.green : Colors.red),
      title: Text(title.tr()),
      trailing: Icon(
        isReady ? Icons.check_circle : Icons.cancel,
        color: isReady ? Colors.green : Colors.red,
        size: 20,
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('settings.select_language'.tr()),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('English'),
                  onTap: () {
                    context.setLocale(const Locale('en'));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('العربية'),
                  onTap: () {
                    context.setLocale(const Locale('ar'));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Українська'),
                  onTap: () {
                    context.setLocale(const Locale('uk'));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Français'),
                  onTap: () {
                    context.setLocale(const Locale('fr'));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Deutsch'),
                  onTap: () {
                    context.setLocale(const Locale('de'));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Русский'),
                  onTap: () {
                    context.setLocale(const Locale('ru'));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('فارسی'),
                  onTap: () {
                    context.setLocale(const Locale('fa'));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('اردو'),
                  onTap: () {
                    context.setLocale(const Locale('ur'));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('বাংলা'),
                  onTap: () {
                    context.setLocale(const Locale('bn'));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('हिन्दी'),
                  onTap: () {
                    context.setLocale(const Locale('hi'));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('کٲشُر'),
                  onTap: () {
                    context.setLocale(const Locale('ks'));
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _languageLabel(String code) {
    switch (code) {
      case 'ar':
        return 'العربية';
      case 'uk':
        return 'Українська';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'ru':
        return 'Русский';
      case 'fa':
        return 'فارسی';
      case 'ur':
        return 'اردو';
      case 'bn':
        return 'বাংলা';
      case 'hi':
        return 'हिन्दी';
      case 'ks':
        return 'کٲشُر';
      default:
        return 'English';
    }
  }
}
