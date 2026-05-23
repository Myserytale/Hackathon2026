import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/animal_viewmodel.dart';
import 'animal_detail_view.dart';
import '../models/animal.dart';

class AnimalListView extends StatelessWidget {
  final String species;
  final List<Animal> animals;
  final bool isStandalone;

  const AnimalListView({
    super.key,
    required this.species,
    required this.animals,
    this.isStandalone = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isStandalone ? 'My $species' : '$species List'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: animals.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final animal = animals[index];
          return Card(
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                child: Text(animal.species[0]),
              ),
              title: Text('Tag: ${animal.tagNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Breed: ${animal.breed ?? 'Unknown'} | Age: ${animal.age} yrs'),
              trailing: Chip(
                label: Text(animal.healthStatus),
                backgroundColor: animal.healthStatus == 'Healthy' ? Colors.green[100] : Colors.orange[100],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AnimalDetailView(animal: animal),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
