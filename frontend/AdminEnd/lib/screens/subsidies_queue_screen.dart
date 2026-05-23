import 'package:flutter/material.dart';
// import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/data_provider.dart';
import '../models/application.dart';
import '../widgets/metric_card.dart';
import '../widgets/validation_modal.dart';

class SubsidiesQueueScreen extends StatelessWidget {
  const SubsidiesQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final currencyFormat = NumberFormat.currency(symbol: '€', decimalDigits: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Coada de Așteptare Subvenții',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => data.loadInitialData(),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Refresh'),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Metrics Row
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Dosare în Așteptare',
                value: data.applications
                    .where((a) => a.status == ApplicationStatus.pending)
                    .length
                    .toString(),
                icon: Icons.schedule,
                color: const Color(0xFF0277BD),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: MetricCard(
                title: 'Aprobate Astăzi',
                value: data.applications
                    .where((a) => a.status == ApplicationStatus.approved)
                    .length
                    .toString(),
                icon: Icons.check_circle,
                color: const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: MetricCard(
                title: 'Valoare Totală Dosare',
                value: currencyFormat.format(
                  data.applications.fold(
                    0.0,
                    (sum, a) => sum + a.requestedAmount,
                  ),
                ),
                icon: Icons.euro,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Table Area
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: data.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: DataTable(
                        columnSpacing: 24,
                        headingRowColor: WidgetStateProperty.all(
                          const Color(0xFFF9FAFB),
                        ),
                        columns: const [
                          DataColumn(
                            label: Text(
                              'ID Dosar',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Fermier',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Locație',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Bovine',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Suma Cerută',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Status',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Acțiuni',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        rows: data.applications.map((app) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  app.id,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              DataCell(Text(app.farmerName)),
                              DataCell(Text(app.farmLocation)),
                              DataCell(Text(app.bovineCount.toString())),
                              DataCell(
                                Text(
                                  currencyFormat.format(app.requestedAmount),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataCell(_StatusBadge(status: app.status)),
                              DataCell(
                                app.status == ApplicationStatus.pending
                                    ? TextButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                FileReviewWizard(
                                                  application: app,
                                                ),
                                          );
                                        },
                                        child: const Text('Review Dosar'),
                                      )
                                    : const Icon(
                                        Icons.check,
                                        color: Colors.green,
                                      ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ApplicationStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case ApplicationStatus.pending:
        color = const Color(0xFF0277BD);
        label = 'ÎN ANALIZĂ';
        break;
      case ApplicationStatus.approved:
        color = const Color(0xFF2E7D32);
        label = 'APROBAT';
        break;
      case ApplicationStatus.rejected:
        color = const Color(0xFFC62828);
        label = 'RESPINS';
        break;
      case ApplicationStatus.needsFix:
        color = Colors.orange;
        label = 'NECESITĂ CLARIFICĂRI';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26), // ~0.1 opacity
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(128)), // ~0.5 opacity
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
