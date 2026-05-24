import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/roeid_theme.dart';
import '../widgets/roeid_ui.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final brand = context.roeid.config;
    final pinTheme = PinTheme(
      width: 52,
      height: 58,
      textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        border: Border.all(color: RoeidTheme.border, width: 1.5),
        borderRadius: BorderRadius.circular(RoeidTheme.radiusInput),
      ),
    );

    return RoeidAuthLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.security_rounded, size: 48, color: brand.primary),
          const SizedBox(height: 16),
          Text('Verificare 2FA', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Introduceți codul de 6 cifre trimis pe adresa dvs. de email.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Pinput(
            length: 6,
            defaultPinTheme: pinTheme,
            focusedPinTheme: pinTheme.copyWith(
              decoration: pinTheme.decoration!.copyWith(
                border: Border.all(color: brand.primary, width: 2),
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
                  const SnackBar(content: Text('Cod incorect'), backgroundColor: RoeidTheme.error),
                );
              }
            },
          ),
          const SizedBox(height: 32),
          if (_isLoading) Center(child: CircularProgressIndicator(color: brand.primary)),
        ],
      ),
    );
  }
}
