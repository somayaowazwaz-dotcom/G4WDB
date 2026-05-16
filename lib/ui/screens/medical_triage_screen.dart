import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../agents/medical_triage/medical_triage_agent.dart';
import '../widgets/voice_input.dart';

class MedicalTriageScreen extends ConsumerWidget {
  const MedicalTriageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final triageAgent = ref.watch(medicalTriageAgentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Triage Agent'),
        backgroundColor: Colors.red[900],
      ),
      body: Column(
        children: [
          Expanded(
            child: triageAgent.currentResult == null
                ? const Center(child: Text('Awaiting patient data...'))
                : _buildResultView(triageAgent),
          ),
          if (triageAgent.isProcessing)
            const LinearProgressIndicator(color: Colors.red),
          _buildInputArea(context, ref),
        ],
      ),
    );
  }

  Widget _buildResultView(MedicalTriageAgent agent) {
    final result = agent.currentResult!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: _getPriorityColor(result.priority),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  result.category.toUpperCase(),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'Priority: ${result.priority}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Immediate Actions:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ...result.actions.map((action) => ListTile(
          leading: const Icon(Icons.warning, color: Colors.orange),
          title: Text(action),
        )),
        const Divider(),
        const Text('Treatment Steps:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ...result.treatments.map((step) => ListTile(
          leading: const Icon(Icons.check_circle_outline, color: Colors.green),
          title: Text(step),
        )),
      ],
    );
  }

  Widget _buildInputArea(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)],
      ),
      child: Row(
        children: [
          Expanded(
            child: VoiceInputWidget(
              onResult: (text) {
                ref.read(medicalTriageAgentProvider).assessPatient(symptoms: text);
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () {
              // Image input logic
            },
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'RED': return Colors.red;
      case 'YELLOW': return Colors.orange;
      case 'GREEN': return Colors.green;
      case 'BLACK': return Colors.black;
      default: return Colors.grey;
    }
  }
}
