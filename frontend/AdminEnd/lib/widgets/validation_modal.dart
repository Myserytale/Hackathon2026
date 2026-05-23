import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/application.dart';
import '../providers/data_provider.dart';

class FileReviewWizard extends StatelessWidget {
  final Application application;

  const FileReviewWizard({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '€', decimalDigits: 0);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 1000,
        height: 700,
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(LucideIcons.fileSearch, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Analiză Dosar: ${application.id}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x),
                ),
              ],
            ),
            const Divider(height: 40),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Side: Data
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'INFORMAȚII FERMIER',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _InfoRow(
                          label: 'Nume Complet',
                          value: application.farmerName,
                        ),
                        _InfoRow(
                          label: 'Locație Fermă',
                          value: application.farmLocation,
                        ),
                        _InfoRow(
                          label: 'Efectiv Bovine',
                          value: '${application.bovineCount} capete',
                        ),
                        _InfoRow(
                          label: 'Suma Solicitată',
                          value: currencyFormat.format(
                            application.requestedAmount,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'DOCUMENTE ÎNCĂRCATE',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...application.documents.map(
                          (doc) => _DocumentItem(name: doc),
                        ),
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 60),
                  // Right Side: Actions
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'VERIFICĂRI SISTEM (VET-LINK)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const _StatusCheck(
                          label: 'Status Sanitar-Veterinar',
                          isValid: true,
                        ),
                        const _StatusCheck(
                          label: 'Înregistrare RNE (ANSVSA)',
                          isValid: true,
                        ),
                        const _StatusCheck(
                          label: 'Suprafață Teren Validată',
                          isValid: true,
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Column(
                            children: [
                              Text(
                                'NOTĂ DE ANALIZĂ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 12),
                              TextField(
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText:
                                      'Adăugați observații sau motivele respingerii...',
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  context
                                      .read<DataProvider>()
                                      .rejectApplication(
                                        application.id,
                                        'Documentație incompletă',
                                      );
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFC62828),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                  ),
                                ),
                                child: const Text('RESPINGE DOSAR'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  context
                                      .read<DataProvider>()
                                      .approveApplication(application.id);
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E7D32),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                  ),
                                ),
                                child: const Text('APROBĂ FINANȚARE'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _DocumentItem extends StatelessWidget {
  final String name;

  const _DocumentItem({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.fileText, size: 18, color: Color(0xFF1976D2)),
          const SizedBox(width: 12),
          Text(
            name,
            style: const TextStyle(
              color: Color(0xFF1976D2),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          const Icon(LucideIcons.eye, size: 16, color: Color(0xFF1976D2)),
        ],
      ),
    );
  }
}

class _StatusCheck extends StatelessWidget {
  final String label;
  final bool isValid;

  const _StatusCheck({required this.label, required this.isValid});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            isValid ? LucideIcons.checkCircle2 : LucideIcons.alertCircle,
            color: isValid ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
