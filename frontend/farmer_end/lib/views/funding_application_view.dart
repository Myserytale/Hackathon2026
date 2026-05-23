import 'package:flutter/material.dart';

class FundingApplicationView extends StatefulWidget {
  const FundingApplicationView({super.key});

  @override
  State<FundingApplicationView> createState() => _FundingApplicationViewState();
}

class _FundingApplicationViewState extends State<FundingApplicationView> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  String _farmName = '';
  String _iban = '';
  String _animalTag = '';
  
  List<Offset?> _points = [];

  void _submitApplication() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_points.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vă rugăm să semnați digital documentul!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Simulate sending to backend
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dosarul a fost trimis cu succes către Veterinar!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _downloadPhysical() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF-ul a fost descărcat pentru semnare fizică.'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          header: true,
          child: const Text('Grant Naștere Vițel (400€)'),
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          controlsBuilder: (context, details) {
            if (_currentStep == 2) {
              return const SizedBox.shrink(); // Hide default controls on last step
            }
            return Row(
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: const Text('Continuă'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Înapoi'),
                ),
              ],
            );
          },
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() => _currentStep += 1);
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep -= 1);
            }
          },
          steps: [
            Step(
              title: const Text('Date Exploatație'),
              content: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Nume Fermă / PFA',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value!.isEmpty ? 'Necesar' : null,
                    onSaved: (val) => _farmName = val!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'IBAN (pentru plata grantului)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value!.isEmpty ? 'Necesar' : null,
                    onSaved: (val) => _iban = val!,
                  ),
                ],
              ),
              isActive: _currentStep >= 0,
            ),
            Step(
              title: const Text('Date Vițel (Naștere)'),
              content: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Crotalia Mamei (ex. RO123456)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.qr_code_scanner),
                    ),
                    validator: (value) => value!.isEmpty ? 'Necesar' : null,
                    onSaved: (val) => _animalTag = val!,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Formularul F1 de identificare va fi precompletat și atașat automat dosarului.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  )
                ],
              ),
              isActive: _currentStep >= 1,
            ),
            Step(
              title: const Text('Previzualizare, Semnare & Trimitere'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Documente Autogenerate:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.picture_as_pdf, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Cerere_Grant_APIA.pdf', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(),
                        Row(
                          children: [
                            const Icon(Icons.picture_as_pdf, color: Colors.red),
                            const SizedBox(width: 8),
                            const Text('Formular_F1_Veterinar.pdf', style: TextStyle(fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('Așteaptă viza Vet', style: TextStyle(color: Colors.orange, fontSize: 10)),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  OutlinedButton.icon(
                    onPressed: _downloadPhysical,
                    icon: const Icon(Icons.download),
                    label: const Text('Descarcă PDF pentru semnare fizică'),
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: Text('- SAU SEMNEAZĂ DIGITAL -', style: TextStyle(color: Colors.grey))),
                  ),
                  
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          RenderBox renderBox = context.findRenderObject() as RenderBox;
                          _points.add(details.localPosition);
                        });
                      },
                      onPanEnd: (details) {
                        setState(() {
                          _points.add(null);
                        });
                      },
                      child: CustomPaint(
                        painter: SignaturePainter(_points),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _points.clear()),
                    child: const Text('Șterge Semnătura'),
                  ),
                  
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _submitApplication,
                    child: const Text('Cere Viza Veterinarului', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
              isActive: _currentStep >= 2,
            ),
          ],
        ),
      ),
    );
  }
}

class SignaturePainter extends CustomPainter {
  List<Offset?> points;

  SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => true;
}
