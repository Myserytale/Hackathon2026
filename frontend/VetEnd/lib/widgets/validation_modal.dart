import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alert.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';

class ValidationModal extends StatefulWidget {
  final Alert alert;

  const ValidationModal({super.key, required this.alert});

  @override
  State<ValidationModal> createState() => _ValidationModalState();
}

class _ValidationModalState extends State<ValidationModal> {
  final List<Offset?> _points = [];
  bool _isSubmitting = false;

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
    
    final bgRect = Rect.fromLTWH(0, 0, width, height);
    canvas.drawRect(bgRect, Paint()..color = Colors.white);

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

  void _submit() async {
    if (_points.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vă rugăm să semnați documentul.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final sigBase64 = await _getSignatureBase64();
    if (sigBase64 != null) {
      await context.read<DataService>().validateAlert(widget.alert.dossierId, sigBase64);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Aprobat! Formularul F1 a fost generat și trimis la APIA."),
            backgroundColor: AppTheme.primaryAction,
          ),
        );
      }
    }
    
    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Revizuire Dosar Grant", style: Theme.of(context).textTheme.headlineMedium),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, size: 40),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Fermier: ${widget.alert.farmerName}",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            "Crotalie Animal: ${widget.alert.animalTag}",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          const Text('Semnătura Medic Veterinar:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.primaryAction, width: 2),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[100],
            ),
            child: Stack(
              children: [
                if (_points.isEmpty)
                  const Center(child: Text("Semnați aici...", style: TextStyle(color: Colors.grey))),
                GestureDetector(
                  onPanUpdate: (details) {
                    setState(() => _points.add(details.localPosition));
                  },
                  onPanEnd: (details) {
                    setState(() => _points.add(null));
                  },
                  child: CustomPaint(
                    painter: SignaturePainter(_points),
                    size: Size.infinite,
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _points.clear()),
                    tooltip: "Șterge Semnătura",
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.verified, size: 32),
              label: const Text("Aprobă Dosarul & Emite F1"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 80),
                backgroundColor: AppTheme.primaryAction,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => oldDelegate.points != points;
}
