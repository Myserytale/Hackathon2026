import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/animal.dart';
import '../viewmodels/animal_viewmodel.dart';

class ReportDeathListView extends StatelessWidget {
  final String species;
  final List<Animal> animals;
  final bool isStandalone;

  const ReportDeathListView({
    super.key,
    required this.species,
    required this.animals,
    this.isStandalone = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isStandalone ? 'Report $species Death' : '$species List'),
        backgroundColor: Colors.red[50],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: animals.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final animal = animals[index];
          return Card(
            elevation: 1,
            child: ListTile(
              leading: CircleAvatar(child: Text(animal.species[0])),
              title: Text('Tag: ${animal.tagNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Breed: ${animal.breed ?? 'Unknown'} | Age: ${animal.age} yrs'),
              trailing: const Icon(Icons.remove_circle_outline, color: Colors.red),
              onTap: () => _confirmDeath(context, animal),
            ),
          );
        },
      ),
    );
  }

  void _confirmDeath(BuildContext context, Animal animal) {
    final viewModel = context.read<AnimalViewModel>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Death Report'),
        content: Text('Are you sure you want to report the death of animal with Tag: ${animal.tagNumber}? This will remove them from your inventory permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog first
              
              await viewModel.removeAnimal(animal.id!);
              
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text('Removed animal with Tag: ${animal.tagNumber} from inventory'),
                  backgroundColor: Colors.red,
                ),
              );
              
              if (context.mounted) {
                Navigator.pop(context); // Return to previous screen
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
