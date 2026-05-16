import 'package:flutter/material.dart';

class MetricsDashboard extends StatelessWidget {
  final String batteryLife;
  final String latency;
  final String meshDelivery;
  final bool offlineMode;

  const MetricsDashboard({
    super.key,
    required this.batteryLife,
    required this.latency,
    required this.meshDelivery,
    required this.offlineMode,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Metrics',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            _buildMetricRow('Battery Life', batteryLife),
            _buildMetricRow('Latency', latency),
            _buildMetricRow('Mesh Delivery', meshDelivery),
            _buildMetricRow('Offline Mode', offlineMode ? 'Enabled' : 'Disabled'),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
