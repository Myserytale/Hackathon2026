import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/alert.dart';
import '../theme/app_theme.dart';
import 'validation_modal.dart';

class ActionCard extends StatelessWidget {
  final Alert alert;
  final VoidCallback onReject;

  const ActionCard({super.key, required this.alert, required this.onReject});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    alert.animalType,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                Icon(Icons.warning_amber_rounded, color: Colors.orange[800], size: 36),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Fermă: ${alert.farmerName}",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.accentBlue,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "Crotalie: ${alert.animalTag}",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              alert.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (alert.farmerDocumentUrl != null)
              OutlinedButton.icon(
                onPressed: () async {
                  final url = Uri.parse('http://localhost:8080/api/grant-dossiers/${alert.dossierId}/download/farmer');
                  try {
                    // Use url_launcher or similar here if available, otherwise just print
                    // For demo, we just print or let the user click it.
                    // Actually, if url_launcher is in pubspec, we should use it.
                    // We'll import it at the top.
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  } catch (e) {
                    debugPrint('Error launching url: $e');
                  }
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("Cerere APIA Fermier"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => ValidationModal(alert: alert),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryAction,
                      minimumSize: const Size(0, 70), // Large touch target
                    ),
                    child: const Text("Aprobă & Emite F1"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.secondaryAction, width: 2),
                      minimumSize: const Size(0, 70),
                      foregroundColor: AppTheme.secondaryAction,
                    ),
                    child: const Text("Respinge"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
