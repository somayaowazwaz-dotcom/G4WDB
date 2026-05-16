import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/routes.dart';
import '../../core/services/model_manager.dart';
import '../../core/gemma_engine/gemma_core.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _downloadProgress = 0.0;
  bool _isDownloading = false;
  String _statusMessage = 'Initializing...';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkModelAndInitialize();
  }

  Future<void> _checkModelAndInitialize() async {
    final modelManager = ModelManager.instance;
    final isDownloaded = await modelManager.isModelDownloaded();

    if (!isDownloaded) {
      _startDownload();
    } else {
      _finishInitialization();
    }
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _statusMessage = 'Downloading AI Model (approx. 2.4GB)...';
    });

    await ModelManager.instance.downloadModel(
      onProgress: (progress) {
        setState(() {
          _downloadProgress = progress;
        });
      },
      onComplete: (path) {
        _finishInitialization();
      },
      onError: (error) {
        setState(() {
          _isDownloading = false;
          _errorMessage = 'Download failed: $error';
        });
      },
    );
  }

  Future<void> _finishInitialization() async {
    setState(() {
      _isDownloading = false;
      _downloadProgress = 1.0;
      _statusMessage = 'Initializing AI Engine...';
    });

    try {
      await GemmaCore.instance.initialize();
    } catch (e) {
      debugPrint('Core init error: $e');
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/G4WDBLogo.png',
                height: 120,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.security,
                  size: 80,
                  color: Colors.orange,
                ),
              ).animate().scale(duration: 500.ms).shake(),
              const SizedBox(height: 24),
              Text(
                'G4WDB AI Agent',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 8),
              Text(
                'Offline Humanitarian Response',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 48),
              
              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _errorMessage = null);
                    _checkModelAndInitialize();
                  },
                  child: const Text('Retry Download'),
                ),
              ] else ...[
                if (_isDownloading) ...[
                  LinearProgressIndicator(
                    value: _downloadProgress,
                    backgroundColor: Colors.white10,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${(_downloadProgress * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                ] else
                  const CircularProgressIndicator(color: Colors.orange),
                
                const SizedBox(height: 16),
                Text(
                  _statusMessage,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
