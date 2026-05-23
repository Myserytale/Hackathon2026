import 'package:flutter/material.dart';
import '../models/animal.dart';

class AnimalDetailView extends StatelessWidget {
  final Animal animal;

  const AnimalDetailView({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    final birthDateStr = animal.birthDate != null
        ? '${animal.birthDate!.year}-${animal.birthDate!.month.toString().padLeft(2, '0')}-${animal.birthDate!.day.toString().padLeft(2, '0')}'
        : 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: Text('Tag: ${animal.tagNumber}'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                child: Text(animal.species[0], style: const TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(height: 24),
            _infoRow(Icons.pets, 'Species', animal.species),
            _infoRow(Icons.category, 'Breed', animal.breed ?? 'Unknown'),
            _infoRow(Icons.cake, 'Age', '${animal.age} years'),
            _infoRow(Icons.calendar_today, 'Birth Date', birthDateStr),
            _infoRow(Icons.health_and_safety, 'Health Status', animal.healthStatus),
            _infoRow(Icons.person, 'Owner ID', animal.ownerId?.toString() ?? 'Unknown'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
