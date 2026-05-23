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
  bool _isScanning = false;
  bool _scanned = false;

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
              Text("Validare Fizică", style: Theme.of(context).textTheme.displayLarge),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, size: 40),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            "Identificare animal: ${widget.alert.farmerName} - ${widget.alert.animalType}",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.charcoal, width: 2, style: BorderStyle.solid),
              ),
              child: _scanned
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, color: AppTheme.primaryAction, size: 100),
                          const SizedBox(height: 16),
                          Text("Crotalie scanată: RO-887231",
                              style: Theme.of(context).textTheme.headlineMedium),
                        ],
                      ),
                    )
                  : InkWell(
                      onTap: () async {
                        setState(() => _isScanning = true);
                        await Future.delayed(const Duration(seconds: 2));
                        setState(() {
                          _isScanning = false;
                          _scanned = true;
                        });
                      },
                      child: Center(
                        child: _isScanning
                            ? const CircularProgressIndicator(color: AppTheme.primaryAction)
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.camera_alt, size: 80, color: AppTheme.charcoal),
                                  const SizedBox(height: 16),
                                  Text("Atingeți pentru a scana crotalia fizică",
                                      style: Theme.of(context).textTheme.bodyLarge),
                                ],
                              ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _scanned
                  ? () {
                      context.read<DataService>().validateAlert(widget.alert.id);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Validat și semnat matematic. Înregistrat în Ledger."),
                          backgroundColor: AppTheme.primaryAction,
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.fingerprint, size: 32),
              label: const Text("Semnează Matematic"),
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
