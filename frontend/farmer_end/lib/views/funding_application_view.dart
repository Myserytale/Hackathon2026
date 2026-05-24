import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import '../config/api_config.dart';
import '../viewmodels/animal_viewmodel.dart';

class FundingApplicationView extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const FundingApplicationView({super.key, this.initialData});

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

  // Vet selection
  List<Map<String, dynamic>> _vets = [];
  Map<String, dynamic>? _selectedVet;
  bool _loadingVets = true;

  // Dossier result after submit
  int? _dossierId;
  String? _documentUrl;
  bool _isSubmitting = false;

  // Upload state
  bool _isUploading = false;
  String? _uploadedFileName;
  String? _uploadedFilePath;

  @override
  void initState() {
    super.initState();
    _fetchVets();
    if (widget.initialData != null) {
      _dossierId = widget.initialData!['id'];
      if (widget.initialData!['animal'] != null) {
        _animalTag = widget.initialData!['animal']['tagNumber'] ?? '';
      }
      if (widget.initialData!['farmer'] != null) {
        _farmName = widget.initialData!['farmer']['username'] ?? '';
      }
    }
  }

  Future<void> _fetchVets() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/users/vets'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _vets = data.cast<Map<String, dynamic>>();
          _loadingVets = false;
        });
      } else {
        setState(() => _loadingVets = false);
      }
    } catch (e) {
      debugPrint('Error fetching vets: $e');
      setState(() => _loadingVets = false);
    }
  }

  Future<String?> _getSignatureBase64() async {
    if (_points.isEmpty) return null;

    double minX = double.infinity, minY = double.infinity;
    double maxX = double.negativeInfinity, maxY = double.negativeInfinity;
    for (final p in _points) {
      if (p != null) {
        if (p.dx < minX) minX = p.dx;
        if (p.dy < minY) minY = p.dy;
        if (p.dx > maxX) maxX = p.dx;
        if (p.dy > maxY) maxY = p.dy;
      }
    }
    if (minX == double.infinity) return null;

    minX = (minX - 10).clamp(0.0, double.infinity);
    minY = (minY - 10).clamp(0.0, double.infinity);
    maxX += 10;
    maxY += 10;

    final width = maxX - minX;
    final height = maxY - minY;
    
    if (width <= 0 || height <= 0) return null;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    // Draw white background so PDF renders it perfectly without transparency issues
    final bgRect = Rect.fromLTWH(0, 0, width, height);
    canvas.drawRect(bgRect, Paint()..color = Colors.white);

    // Shift drawing context so the bounding box fits exactly into the image
    canvas.translate(-minX, -minY);

    final painter = SignaturePainter(_points);
    painter.paint(canvas, Size.infinite);
    
    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;
    
    final buffer = byteData.buffer.asUint8List();
    return base64Encode(buffer);
  }

  Future<void> _generateDraft() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    try {
      final signatureBase64 = await _getSignatureBase64();
      final payload = {
        'farmerId': 1,
        'animalId': 1, // Mock
        'farmName': _farmName,
        'animalTag': _animalTag,
        'iban': _iban,
        'isDraft': true,
      };
      if (signatureBase64 != null) {
        payload['signatureBase64'] = signatureBase64;
      }
      if (_dossierId != null) {
        payload['dossierId'] = _dossierId as int;
      }
      
      final response = await http.post(
        Uri.parse('${ApiConfig.apiBaseUrl}/grant-dossiers/submit-farmer'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _dossierId = data['dossierId'];
          _documentUrl = data['documentUrl'];
        });
      }
    } catch (e) {
      debugPrint('Error generating draft: $e');
    }
  }

  void _submitApplication() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_selectedVet == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selectați un veterinar!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_points.isEmpty && _uploadedFileName == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semnați digital sau încărcați documentul semnat!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      setState(() => _isSubmitting = true);

      final authService = Provider.of<AuthService>(context, listen: false);
      final token = authService.token;

      try {
        final signatureBase64 = await _getSignatureBase64();
        final payload = {
          'farmerId': 1,
          'animalId': 1,
          'farmName': _farmName,
          'animalTag': _animalTag,
          'iban': _iban,
          'veterinarianId': _selectedVet!['id'],
          'isDraft': false,
        };
        if (signatureBase64 != null) {
          payload['signatureBase64'] = signatureBase64;
        }
        if (_dossierId != null) {
          payload['dossierId'] = _dossierId as int;
        }

        final response = await http.post(
          Uri.parse('${ApiConfig.apiBaseUrl}/grant-dossiers/submit-farmer'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final dossierId = data['dossierId'];
          setState(() {
            _dossierId = dossierId;
            _documentUrl = data['documentUrl'];
          });
          
          if (_uploadedFileName != null && _uploadedFilePath != null) {
            var request = http.MultipartRequest(
              'POST',
              Uri.parse('${ApiConfig.apiBaseUrl}/grant-dossiers/$dossierId/upload-signed'),
            );
            request.headers['Authorization'] = 'Bearer $token';
            request.fields['docType'] = 'farmer';
            request.files.add(await http.MultipartFile.fromPath('file', _uploadedFilePath!));
            await request.send();
          }

          setState(() => _isSubmitting = false);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Dosarul a fost creat și trimis către ${_selectedVet!['username']}!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          setState(() => _isSubmitting = false);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Eroare: ${response.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() => _isSubmitting = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare de conexiune: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadPdf() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Se generează PDF-ul pentru semnare...'),
        backgroundColor: Colors.blue,
      ),
    );
    
    // Save form fields first so we can use them in draft
    _formKey.currentState?.save();
    await _generateDraft();
    
    if (_dossierId != null) {
      final url = Uri.parse('${ApiConfig.apiBaseUrl}/grant-dossiers/$_dossierId/download/farmer');
      try {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('Could not launch URL: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Eroare la generarea documentului.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadSignedPdf() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        dialogTitle: 'Selectați PDF-ul semnat (Cerere_Grant_APIA.pdf)',
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final fileName = result.files.single.name;

        if (!fileName.toLowerCase().endsWith('.pdf')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Eroare: Vă rugăm să selectați un fișier PDF!'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        setState(() {
          _uploadedFileName = fileName;
          _uploadedFilePath = filePath;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Documentul "$fileName" a fost atașat și va fi trimis odată cu dosarul.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('File picker error: $e');
    }
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
          onStepTapped: (step) => setState(() => _currentStep = step),
          onStepContinue: () {
            if (_currentStep < 3) {
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
                    initialValue: _farmName,
                    decoration: const InputDecoration(
                      labelText: 'Nume Fermă / PFA',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value!.isEmpty ? 'Necesar' : null,
                    onSaved: (val) => _farmName = val!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _iban,
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
                  Autocomplete<String>(
                    initialValue: TextEditingValue(text: _animalTag),
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      final animalVM = context.read<AnimalViewModel>();
                      final tags = animalVM.animals.map((a) => a.tagNumber).toList();
                      if (textEditingValue.text.isEmpty) {
                        return tags;
                      }
                      return tags.where((String option) {
                        return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) {
                      _animalTag = selection;
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Crotalia Mamei (ex. RO123456)',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.qr_code_scanner),
                        ),
                        validator: (value) => value!.isEmpty ? 'Necesar' : null,
                        onSaved: (val) => _animalTag = val!,
                      );
                    },
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
              title: const Text('Selectare Veterinar'),
              content: _loadingVets
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Selectați veterinarul care va verifica dosarul:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<Map<String, dynamic>>(
                          decoration: InputDecoration(
                            labelText: 'Veterinar',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.medical_services, color: Colors.blue),
                          ),
                          hint: const Text('Alegeți veterinarul...'),
                          isExpanded: true,
                          value: _selectedVet,
                          items: _vets.map((vet) {
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: vet,
                              child: Text(
                                vet['username'] ?? 'Necunoscut',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedVet = value),
                          validator: (value) => value == null ? 'Selectați un veterinar' : null,
                        ),
                      ],
                    ),
              isActive: _currentStep >= 2,
            ),
            Step(
              title: const Text('Previzualizare, Semnare & Trimitere'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Documente din Dosar:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.green.shade400),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3),
                      ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.picture_as_pdf, color: Colors.red),
                            const SizedBox(width: 8),
                            const Expanded(child: Text('Cerere_Grant_APIA.pdf', style: TextStyle(fontWeight: FontWeight.bold))),
                            if (_uploadedFileName != null)
                              const Icon(Icons.check_circle, color: Colors.green, size: 20),
                          ],
                        ),
                        if (_uploadedFileName != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 32),
                            child: Text('Fișier atașat: $_uploadedFileName', style: const TextStyle(color: Colors.green, fontSize: 12)),
                          ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton.icon(
                              onPressed: _downloadPdf,
                              icon: const Icon(Icons.download, size: 18),
                              label: const Text('Descarcă'),
                              style: TextButton.styleFrom(foregroundColor: Colors.blue),
                            ),
                            TextButton.icon(
                              onPressed: _uploadSignedPdf,
                              icon: const Icon(Icons.upload_file, size: 18),
                              label: const Text('Încarcă Semnat'),
                              style: TextButton.styleFrom(foregroundColor: Colors.green),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        const Expanded(child: Text('Formular_F1_Veterinar.pdf', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _selectedVet != null
                                ? 'Așteaptă viza ${_selectedVet!['username']}'
                                : 'Așteaptă viza Vet',
                            style: const TextStyle(color: Colors.orange, fontSize: 10),
                          ),
                        )
                      ],
                    ),
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('- SAU SEMNEAZĂ DIGITAL AICI -', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
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
                          _points.add(details.localPosition);
                        });
                      },
                      onPanEnd: (details) {
                        setState(() => _points.add(null));
                      },
                      child: CustomPaint(
                        painter: SignaturePainter(_points),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => setState(() => _points.clear()),
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text('Șterge Semnătura'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _isSubmitting ? null : _submitApplication,
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_selectedVet != null ? 'Trimite Dosarul către ${_selectedVet!['username']}' : 'Trimite Dosar'),
                  ),
                ],
              ),
              isActive: _currentStep >= 3,
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
