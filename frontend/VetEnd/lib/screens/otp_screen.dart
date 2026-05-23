import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.security, size: 80, color: AppTheme.accentBlue),
              const SizedBox(height: 24),
              Text("Verificare 2FA", style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 16),
              const Text(
                "Introduceți codul primit prin SMS sau Token",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Pinput(
                length: 6,
                defaultPinTheme: PinTheme(
                  width: 60,
                  height: 70,
                  textStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.charcoal, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onCompleted: (pin) async {
                  setState(() => _isLoading = true);
                  final auth = context.read<AuthService>();
                  final success = await auth.verifyOtp(pin);
                  if (!context.mounted) return;
                  setState(() => _isLoading = false);
                  if (success) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Cod incorect")),
                    );
                  }
                },
              ),
              const SizedBox(height: 48),
              if (_isLoading) const CircularProgressIndicator(color: AppTheme.accentBlue),
            ],
          ),
        ),
      ),
    );
  }
}
