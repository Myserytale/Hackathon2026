import 'package:flutter/material.dart';

class VetPortalView extends StatefulWidget {
  const VetPortalView({super.key});

  @override
  State<VetPortalView> createState() => _VetPortalViewState();
}

class _VetPortalViewState extends State<VetPortalView> {
  bool _isApproved = false;

  void _approveDossier() {
    setState(() {
      _isApproved = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dosarul a fost semnat (Formular F1) și trimis către APIA!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejectDossier() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dosarul a fost returnat fermierului pentru corecturi.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portal Veterinar - Aprobări'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Dosare în așteptare',
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
                          'Dosar #8492 - Naștere Vițel',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _isApproved ? Colors.green.shade100 : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _isApproved ? 'Trimis la APIA' : 'Așteaptă Viza',
                            style: TextStyle(
                              color: _isApproved ? Colors.green.shade800 : Colors.orange.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        )
                      ],
                    ),
                    const Divider(),
                    const Text('Fermier: Ion Popescu (Ferma Vulturul)'),
                    const Text('Crotalie Mamă: RO123456'),
                    const SizedBox(height: 16),
                    const Text('Documente:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Row(
                      children: [
                        Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text('Cerere_Grant_APIA.pdf (Semnat Fermier)'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.picture_as_pdf, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Text('Formular_F1.pdf (Necesar Semnătura Ta)'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (!_isApproved)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _rejectDossier,
                            child: const Text('Respinge', style: TextStyle(color: Colors.red)),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _approveDossier,
                            icon: const Icon(Icons.check),
                            label: const Text('Semnează F1 & Trimite'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade800,
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
