import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../agents/family_search/family_search_agent.dart';

class FamilySearchScreen extends ConsumerWidget {
  const FamilySearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyAgent = ref.watch(familySearchAgentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Search'),
        backgroundColor: Colors.purple[900],
      ),
      body: Column(
        children: [
          Expanded(
            child: familyAgent.matches.isEmpty
                ? const Center(child: Text('No active searches or matches found.'))
                : ListView.builder(
                    itemCount: familyAgent.matches.length,
                    itemBuilder: (context, index) {
                      final match = familyAgent.matches[index];
                      return ListTile(
                        leading: const Icon(Icons.person_search, color: Colors.purple),
                        title: Text('Potential Match: ${match['hash']}'),
                        subtitle: Text('Found at: ${match['found_at']}'),
                        trailing: const Icon(Icons.chevron_right),
                      );
                    },
                  ),
          ),
          _buildAddSearchSection(context, ref),
        ],
      ),
    );
  }

  Widget _buildAddSearchSection(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Enter name or description...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.purple),
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                ref.read(familySearchAgentProvider).addPersonToSearch(
                  name: nameController.text,
                  description: 'Searching for missing person',
                );
                nameController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
