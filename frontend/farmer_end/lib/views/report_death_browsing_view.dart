import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/animal_viewmodel.dart';
import 'report_death_list_view.dart';

class ReportDeathBrowsingView extends StatefulWidget {
  const ReportDeathBrowsingView({super.key});

  @override
  State<ReportDeathBrowsingView> createState() => _ReportDeathBrowsingViewState();
}

class _ReportDeathBrowsingViewState extends State<ReportDeathBrowsingView> {
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
            appBar: AppBar(title: const Text('Report Death')),
            body: const Center(child: Text('No animals in inventory.')),
          );
        }

        // SMART LOGIC: If only one type of animal, show the death list directly
        if (speciesList.length == 1) {
          final species = speciesList.first;
          final animals = categorized[species] ?? [];
          return ReportDeathListView(
            species: species,
            animals: animals,
            isStandalone: true,
          );
        }

        // Multiple types: Show Category Grid for Death Reporting
        return Scaffold(
          appBar: AppBar(
            title: const Text('Select Category'),
            backgroundColor: Colors.red[50],
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
                      builder: (context) => ReportDeathListView(
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
                        backgroundColor: Colors.red[100],
                        child: Text(
                          species[0],
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        species,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${animals.length} animals',
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
