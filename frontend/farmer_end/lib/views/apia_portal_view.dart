import 'package:flutter/material.dart';

class ApiaPortalView extends StatefulWidget {
  const ApiaPortalView({super.key});

  @override
  State<ApiaPortalView> createState() => _ApiaPortalViewState();
}

class _ApiaPortalViewState extends State<ApiaPortalView> {
  bool _isApproved = false;

  void _approveGrant() {
    setState(() {
      _isApproved = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dosarul a fost aprobat! Plata grantului a fost inițiată.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejectGrant() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dosarul a fost returnat (Lipsă acte/Erori).'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portal APIA - Evaluare Granturi'),
        backgroundColor: Colors.orange.shade800,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Dosare de subvenție (SCZ) primite',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Dosar #8492 - Sprijin Cuplat',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _isApproved ? Colors.green.shade100 : Colors.purple.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _isApproved ? 'GRANT APROBAT' : 'ÎN EVALUARE',
                            style: TextStyle(
                              color: _isApproved ? Colors.green.shade800 : Colors.purple.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        )
                      ],
                    ),
                    const Divider(),
                    const Text('Fermier: Ion Popescu (Ferma Vulturul)'),
                    const Text('IBAN: RO12 XYZW 1234 5678 9000'),
                    const Text('Aviz Veterinar: VALID (Crotalie: RO123456)'),
                    const SizedBox(height: 16),
                    const Text('Pachet Documente:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Text('Cerere_Grant_APIA.pdf (Semnat Fermier)'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Text('Formular_F1.pdf (Semnat și Paravat Vet)'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (!_isApproved)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _rejectGrant,
                            child: const Text('Respinge Dosar', style: TextStyle(color: Colors.red)),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _approveGrant,
                            icon: const Icon(Icons.monetization_on),
                            label: const Text('Aprobă Grant (400€)'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade800,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
