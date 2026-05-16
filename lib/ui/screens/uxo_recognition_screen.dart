import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../../agents/uxo_recognition/uxo_agent.dart';

class UXORecognitionScreen extends ConsumerStatefulWidget {
  const UXORecognitionScreen({super.key});

  @override
  ConsumerState<UXORecognitionScreen> createState() => _UXORecognitionScreenState();
}

class _UXORecognitionScreenState extends ConsumerState<UXORecognitionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(uxoRecognitionAgentProvider).initializeCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    final uxoAgent = ref.watch(uxoRecognitionAgentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('UXO Recognition'),
        backgroundColor: Colors.orange[900],
      ),
      body: Stack(
        children: [
          // Camera Preview
          if (uxoAgent.cameraController != null && uxoAgent.cameraController!.value.isInitialized)
            Stack(
              children: [
                Center(
                  child: CameraPreview(uxoAgent.cameraController!),
                ),
                // Scanning Line Effect
                if (uxoAgent.isProcessing)
                  const ScanningOverlay(),
              ],
            )
          else
            const Center(child: CircularProgressIndicator()),

          // Overlay for results
          if (uxoAgent.currentDetection != null && uxoAgent.currentDetection!.detected)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: _buildDetectionCard(uxoAgent),
            ),

          // Action Button
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton.large(
                onPressed: uxoAgent.isProcessing
                    ? null
                    : () async {
                        final image = await uxoAgent.cameraController?.takePicture();
                        if (image != null) {
                          ref.read(uxoRecognitionAgentProvider).detectUXO(imagePath: image.path);
                        }
                      },
                backgroundColor: Colors.orange,
                child: uxoAgent.isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.camera_enhance),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionCard(UXORecognitionAgent agent) {
    final detection = agent.currentDetection!;
    return Card(
      color: Colors.black.withAlpha(204),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  detection.type,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Risk Level: ${detection.riskLevel}', style: const TextStyle(color: Colors.orange)),
            Text('Safe Distance: ${detection.safeDistance}m', style: const TextStyle(color: Colors.white70)),
            const Divider(color: Colors.white24),
            ...detection.recommendations.map((rec) => Text('• $rec', style: const TextStyle(color: Colors.white))),
          ],
        ),
      ),
    );
  }
}

class ScanningOverlay extends StatelessWidget {
  const ScanningOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Container(
            width: double.infinity,
            height: 2,
            color: Colors.orange.withAlpha(128),
          ).animate(onPlay: (controller) => controller.repeat())
           .moveY(begin: -200, end: 200, duration: 2.seconds, curve: Curves.easeInOut),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.orange.withAlpha(51), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
