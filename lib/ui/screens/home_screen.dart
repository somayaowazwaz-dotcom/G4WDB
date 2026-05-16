import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../agents/mesh_network/mesh_agent.dart';
import '../../agents/silent_mode/silent_mode_agent.dart';
import '../../core/gemma_engine/gemma_core.dart';
import '../../features/accessibility/accessibility_service.dart';
import '../../config/routes.dart';
import '../widgets/agent_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final silentMode = ref.watch(silentModeAgentProvider);
    final meshAgent = ref.watch(meshNetworkAgentProvider);
    final gemmaCore = ref.watch(gemmaCoreProvider);
    final accessibilityService = ref.watch(accessibilityServiceProvider);
    
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar with Logo
            SliverToBoxAdapter(
              child: _buildHeader(
                silentMode.isSilentMode,
                gemmaCore.isInitialized,
                accessibilityService.complianceLabel,
              ),
            ),
            
            // Agents Grid
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildListDelegate([
                  AgentCard(
                    title: 'medical.triage'.tr(),
                    icon: Icons.medical_services,
                    color: Colors.red,
                    imagePath: 'assets/images/medical_triage.png',
                    onTap: () => _navigateToMedicalTriage(),
                  ).animate().fadeIn(delay: 100.ms).slideX(),
                  
                  AgentCard(
                    title: 'uxo.recognition'.tr(),
                    icon: Icons.camera_enhance,
                    color: Colors.orange,
                    imagePath: 'assets/images/uxo_recognition.png',
                    onTap: () => _navigateToUXO(),
                  ).animate().fadeIn(delay: 200.ms).slideX(),
                  
                  AgentCard(
                    title: 'mesh.network'.tr(),
                    icon: Icons.bluetooth,
                    color: Colors.blue,
                    badge: meshAgent.isConnected ? 'Active' : null,
                    imagePath: 'assets/images/mesh_network.png',
                    onTap: () => _navigateToMesh(),
                  ).animate().fadeIn(delay: 300.ms).slideX(),
                  
                  AgentCard(
                    title: 'family.search'.tr(),
                    icon: Icons.people,
                    color: Colors.purple,
                    imagePath: 'assets/images/family_search.png',
                    onTap: () => _navigateToFamilySearch(),
                  ).animate().fadeIn(delay: 400.ms).slideX(),
                  
                  AgentCard(
                    title: 'silent.mode'.tr(),
                    icon: silentMode.isSilentMode 
                        ? Icons.volume_off 
                        : Icons.volume_up,
                    color: Colors.teal,
                    isActive: silentMode.isSilentMode,
                    imagePath: 'assets/images/silent_mode.png',
                    onTap: () => _toggleSilentMode(),
                  ).animate().fadeIn(delay: 500.ms).slideX(),

                  AgentCard(
                    title: 'Survival Tracker',
                    icon: Icons.inventory,
                    color: Colors.green,
                    imagePath: 'assets/images/survival_tracker.png',
                    onTap: () => _navigateToSurvivalTracker(),
                  ).animate().fadeIn(delay: 600.ms).slideX(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(bool isSilentMode, bool isGemmaActive, String complianceLabel) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo and Title
              Row(
                children: [
                  Image.asset(
                    'assets/images/G4WDBLogo.png',
                    height: 40,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.security,
                      size: 40,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'app.title'.tr(),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            isSilentMode ? 'silent.active'.tr() : 'app.online'.tr(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isSilentMode 
                                  ? Colors.teal 
                                  : Colors.grey,
                            ),
                          ),
                          if (isGemmaActive) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.bolt, size: 14, color: Colors.orange),
                            Text(
                              'AI G4 is active',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.18),
                                    offset: Offset(0, 4),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: TextButton(
                                onPressed: () => _navigateToChat(),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  foregroundColor: Colors.black87,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: Text(
                                  'Chat with Gemma 4 offline',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.verified, color: Colors.tealAccent, size: 20),
                  const SizedBox(width: 10),
                  const Icon(Icons.view_in_ar, color: Colors.white70, size: 22),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => _navigateToSettings(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _navigateToMedicalTriage() {
    Navigator.pushNamed(context, AppRoutes.medicalTriage);
  }
  
  void _navigateToUXO() {
    Navigator.pushNamed(context, AppRoutes.uxoRecognition);
  }
  
  void _navigateToMesh() {
    Navigator.pushNamed(context, AppRoutes.meshNetwork);
  }
  
  void _navigateToFamilySearch() {
    Navigator.pushNamed(context, AppRoutes.familySearch);
  }

  void _navigateToSurvivalTracker() {
    Navigator.pushNamed(context, AppRoutes.survivalTracker);
  }

  void _navigateToChat() {
    Navigator.pushNamed(context, AppRoutes.chat);
  }
  
  void _toggleSilentMode() {
    ref.read(silentModeAgentProvider.notifier).toggleSilentMode();
  }
  
  void _navigateToSettings() {
    Navigator.pushNamed(context, AppRoutes.settings);
  }
}
