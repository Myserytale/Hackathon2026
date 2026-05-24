import 'package:flutter/material.dart';
// import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../models/application.dart';
import '../providers/data_provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
                const Icon(Icons.find_in_page, size: 28),
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
                  icon: const Icon(Icons.close),
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
                          label: 'Crotalie Animal',
                          value: application.animalTag,
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
                        if (application.farmerDocumentUrl != null)
                          _DocumentItem(
                            name: 'Cerere_Grant_APIA.pdf',
                            docType: 'farmer',
                            applicationId: application.id,
                          ),
                        if (application.vetDocumentUrl != null)
                          _DocumentItem(
                            name: 'Formular_F1_Veterinar.pdf',
                            docType: 'vet',
                            applicationId: application.id,
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
                        _TracesCheckWidget(tagNumber: application.farmerName.hashCode.toString()),
                        const SizedBox(height: 12),
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
  final String docType;
  final String applicationId;

  const _DocumentItem({required this.name, required this.docType, required this.applicationId});

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
          const Icon(Icons.description, size: 18, color: Color(0xFF1976D2)),
          const SizedBox(width: 12),
          Text(
            name,
            style: const TextStyle(
              color: Color(0xFF1976D2),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.download, size: 20, color: Color(0xFF1976D2)),
            onPressed: () async {
              final url = Uri.parse('http://localhost:8080/api/grant-dossiers/$applicationId/download/$docType');
              try {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } catch (e) {
                debugPrint('Could not launch URL: $e');
              }
            },
          ),
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
            isValid ? Icons.check_circle_outline : Icons.error_outline,
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

class _TracesCheckWidget extends StatefulWidget {
  final String tagNumber;
  const _TracesCheckWidget({required this.tagNumber});
  @override
  State<_TracesCheckWidget> createState() => _TracesCheckWidgetState();
}

class _TracesCheckWidgetState extends State<_TracesCheckWidget> {
  bool _isLoading = false;
  bool? _isValid;

  void _checkTraces() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/api/animals/registry/check/${widget.tagNumber}'));
      if (response.statusCode == 200) {
        setState(() => _isValid = true);
      } else {
        setState(() => _isValid = false);
      }
    } catch (e) {
      setState(() => _isValid = false);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isValid == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : _checkTraces,
          icon: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.public, size: 20),
          label: const Text('Verify TRACES EU Registry'),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE3F2FD), foregroundColor: const Color(0xFF1976D2), elevation: 0),
        ),
      );
    }
    return _StatusCheck(label: 'TRACES EU Registry Validated', isValid: _isValid!);
  }
}
