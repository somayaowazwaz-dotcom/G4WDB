import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../agents/mesh_network/mesh_agent.dart';

class MeshNetworkScreen extends ConsumerStatefulWidget {
  const MeshNetworkScreen({super.key});

  @override
  ConsumerState<MeshNetworkScreen> createState() => _MeshNetworkScreenState();
}

class _MeshNetworkScreenState extends ConsumerState<MeshNetworkScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(meshNetworkAgentProvider).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final meshAgent = ref.watch(meshNetworkAgentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesh Network Status'),
        backgroundColor: Colors.blue[900],
      ),
      body: Column(
        children: [
          _buildStatusHeader(meshAgent),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Connected Nodes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: meshAgent.connectedDevices.isEmpty
                ? const Center(child: Text('Searching for nearby nodes...'))
                : ListView.builder(
                    itemCount: meshAgent.connectedDevices.length,
                    itemBuilder: (context, index) {
                      final deviceId = meshAgent.connectedDevices[index];
                      return ListTile(
                        leading: const Icon(Icons.router, color: Colors.blue),
                        title: Text('Node: $deviceId'),
                        subtitle: const Text('Signal Strength: Strong'),
                        trailing: const Icon(Icons.check_circle, color: Colors.green),
                      );
                    },
                  ),
          ),
          _buildActionButtons(context, ref),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(MeshNetworkAgent agent) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.blue.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Delivery Rate', '${agent.deliveryRate}%', Icons.send),
          _buildStatItem('Active Nodes', '${agent.connectedDevices.length}', Icons.hub),
          _buildStatItem('Status', agent.isConnected ? 'Connected' : 'Searching', Icons.wifi_tethering),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Broadcast beacon logic
              },
              icon: const Icon(Icons.broadcast_on_personal),
              label: const Text('Send Beacon'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
