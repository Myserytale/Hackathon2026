import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/animal_viewmodel.dart';
import 'animal_list_view.dart';
import 'animal_detail_view.dart';

class AnimalBrowsingView extends StatefulWidget {
  const AnimalBrowsingView({super.key});

  @override
  State<AnimalBrowsingView> createState() => _AnimalBrowsingViewState();
}

class _AnimalBrowsingViewState extends State<AnimalBrowsingView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnimalViewModel>().loadAnimals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnimalViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Loading...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final speciesList = viewModel.speciesList;
        final categorized = viewModel.categorizedAnimals;

        if (speciesList.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('My Animals')),
            body: const Center(child: Text('No animals found.')),
          );
        }

        // SMART LOGIC: If only one type of animal, show the list directly
        if (speciesList.length == 1) {
          final species = speciesList.first;
          final animals = categorized[species] ?? [];
          return AnimalListView(
            species: species,
            animals: animals,
            isStandalone: true, // Tell the list view it's acting as the main screen
          );
        }

        // Multiple types: Show Category Grid
        return Scaffold(
          appBar: AppBar(
            title: const Text('Animal Categories'),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
          body: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: speciesList.length,
            itemBuilder: (context, index) {
              final species = speciesList[index];
              final animals = categorized[species] ?? [];
              
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnimalListView(
                        species: species,
                        animals: animals,
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                        child: Text(
                          species[0],
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        species,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${animals.length} ${animals.length == 1 ? 'animal' : 'animals'}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
