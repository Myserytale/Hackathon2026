import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/hash_chip.dart';

class LedgerScreen extends StatelessWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trail = context.watch<DataService>().auditTrail;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              const Icon(Icons.verified_user, color: AppTheme.ledgerGreen, size: 40),
              const SizedBox(width: 16),
              Text("Registru Imutabil", style: Theme.of(context).textTheme.displayLarge),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: trail.length,
            separatorBuilder: (context, index) => const Divider(height: 40),
            itemBuilder: (context, index) {
              final entry = trail[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.radio_button_checked, color: AppTheme.ledgerGreen),
                      Container(width: 2, height: 80, color: Colors.grey[300]),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.action, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                            Text(
                              DateFormat('HH:mm - dd MMM').format(entry.timestamp),
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text("ID Entitate: ${entry.entityId}", style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 12),
                        HashChip(hash: entry.hash),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
