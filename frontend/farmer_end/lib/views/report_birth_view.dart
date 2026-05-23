import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/animal.dart';
import '../viewmodels/animal_viewmodel.dart';
import 'dart:math';

class ReportBirthView extends StatefulWidget {
  const ReportBirthView({super.key});

  @override
  State<ReportBirthView> createState() => _ReportBirthViewState();
}

class _ReportBirthViewState extends State<ReportBirthView> {
  final _formKey = GlobalKey<FormState>();
  final _tagNumberController = TextEditingController();
  final _breedController = TextEditingController();
  String? _selectedSpecies;
  DateTime _selectedBirthDate = DateTime.now();

  final List<String> _animalTypes = [
    'Cow',
    'Sheep',
    'Chicken',
    'Pig',
    'Goat',
    'Horse',
    'Duck',
    'Rabbit',
    'Other'
  ];

  @override
  void dispose() {
    _tagNumberController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedSpecies != null) {
      final newAnimal = Animal(
        tagNumber: _tagNumberController.text,
        species: _selectedSpecies!,
        breed: _breedController.text.isNotEmpty ? _breedController.text : null,
        birthDate: _selectedBirthDate,
        healthStatus: 'Healthy',
        ownerId: 1,
      );

      context.read<AnimalViewModel>().addAnimal(newAnimal);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reported birth of animal with Tag: ${newAnimal.tagNumber}')),
      );
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final birthDateStr = '${_selectedBirthDate.year}-${_selectedBirthDate.month.toString().padLeft(2, '0')}-${_selectedBirthDate.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report New Birth'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _tagNumberController,
                decoration: const InputDecoration(
                  labelText: 'Tag Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a tag number' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedSpecies,
                decoration: const InputDecoration(
                  labelText: 'Select Species',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.pets),
                ),
                items: _animalTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSpecies = newValue;
                  });
                },
                validator: (value) => value == null ? 'Please select a species' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(
                  labelText: 'Breed (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedBirthDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedBirthDate = pickedDate;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Birth Date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(birthDateStr, style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Submit Report', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
