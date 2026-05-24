import 'package:flutter/material.dart';
import '../models/animal.dart';
import '../services/document_service.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:file_picker/file_picker.dart';

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
        title: Text(animal.name != null ? '${animal.name} (${animal.tagNumber})' : 'Tag: ${animal.tagNumber}'),
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
            if (animal.name != null) _infoRow(Icons.badge, 'Name', animal.name!),
            if (animal.type != null) _infoRow(Icons.category, 'Type', animal.type!),
            _infoRow(Icons.pets, 'Species', animal.species),
            _infoRow(Icons.category, 'Breed', animal.breed ?? 'Unknown'),
            _infoRow(Icons.cake, 'Age', '${animal.age} years'),
            _infoRow(Icons.calendar_today, 'Birth Date', birthDateStr),
            _infoRow(Icons.health_and_safety, 'Health Status', animal.healthStatus),
            _infoRow(Icons.person, 'Owner ID', animal.ownerId?.toString() ?? 'Unknown'),
            const SizedBox(height: 32),
            Center(
              child: Semantics(
                label: 'Upload Animal Passport or Movement Document',
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Document'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf', 'jpg', 'png'],
                      withData: true,
                    );

                    if (result != null && result.files.single.bytes != null) {
                      final fileBytes = result.files.single.bytes!.toList();
                      final fileName = result.files.single.name;

                      bool success = await DocumentService().uploadDocument(
                        animal.id.toString(),
                        'PASSPORT',
                        fileBytes,
                        fileName,
                        Provider.of<AuthService>(context, listen: false).token!,
                      );
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? 'Document Uploaded Successfully!' : 'Upload Failed.'),
                            backgroundColor: success ? Colors.green : Colors.red,
                          ),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No file selected')),
                        );
                      }
                    }
                  },
                ),
              ),
            ),
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
