import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../agents/survival_tracker/survival_agent.dart';
import '../../models/survival_supply.dart';

class SurvivalTrackerScreen extends ConsumerWidget {
  const SurvivalTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agent = ref.watch(survivalAgentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Survival Tracker'),
        backgroundColor: Colors.green[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => agent.deductDailyUsage(),
            tooltip: 'Deduct Daily Usage',
          ),
        ],
      ),
      body: agent.isInitialized
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHouseholdCard(context, ref, agent),
                const SizedBox(height: 24),
                const Text(
                  'Supply Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...agent.supplies.map((supply) => _buildSupplyTile(context, ref, agent, supply)),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSupplyDialog(context, ref),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHouseholdCard(BuildContext context, WidgetRef ref, SurvivalAgent agent) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.people, size: 32, color: Colors.green),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Household Size', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('${agent.householdSize} persons'),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => agent.setHouseholdSize(agent.householdSize - 1),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => agent.setHouseholdSize(agent.householdSize + 1),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSupplyTile(BuildContext context, WidgetRef ref, SurvivalAgent agent, SurvivalSupply supply) {
    final color = supply.status == "CRITICAL"
        ? Colors.red
        : supply.status == "LOW"
            ? Colors.orange
            : Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(supply.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${supply.totalAmount} ${supply.unit} total'),
            Text('Usage: ${supply.dailyUsage * agent.householdSize} ${supply.unit}/day'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${supply.daysRemaining.toStringAsFixed(1)} days',
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(supply.status, style: TextStyle(color: color, fontSize: 10)),
          ],
        ),
        onTap: () => _showEditAmountDialog(context, ref, supply),
      ),
    );
  }

  void _showAddSupplyDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final usageController = TextEditingController();
    final unitController = TextEditingController(text: 'units');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Supply'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name (e.g. Water)')),
              TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Initial Amount'), keyboardType: TextInputType.number),
              TextField(controller: usageController, decoration: const InputDecoration(labelText: 'Daily Usage per person'), keyboardType: TextInputType.number),
              TextField(controller: unitController, decoration: const InputDecoration(labelText: 'Unit (L, kcal, etc.)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final supply = SurvivalSupply(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text,
                totalAmount: double.tryParse(amountController.text) ?? 0,
                dailyUsage: double.tryParse(usageController.text) ?? 0,
                unit: unitController.text,
                category: 'General',
              );
              ref.read(survivalAgentProvider).addSupply(supply);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditAmountDialog(BuildContext context, WidgetRef ref, SurvivalSupply supply) {
    final controller = TextEditingController(text: supply.totalAmount.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update ${supply.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Total amount (${supply.unit})'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final newAmount = double.tryParse(controller.text) ?? supply.totalAmount;
              ref.read(survivalAgentProvider).updateSupply(supply.copyWith(totalAmount: newAmount));
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
