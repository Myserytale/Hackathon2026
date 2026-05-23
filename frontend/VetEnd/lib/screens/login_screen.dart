import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'otp_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.account_balance, size: 80, color: AppTheme.accentBlue),
                        const SizedBox(height: 24),
                        Text("ROeID", style: Theme.of(context).textTheme.displayLarge),
                        Text("Portal Guvernamental Veterinar",
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 48),
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: "Email Instituțional",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: "Parolă",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    setState(() => _isLoading = true);
                                    final auth = context.read<AuthService>();
                                    final success = await auth.login(_emailController.text, _passwordController.text);
                                    if (!context.mounted) return;
                                    setState(() => _isLoading = false);
                                    if (success) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const OtpScreen()),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(auth.errorMessage ?? "Date incorecte")),
                                      );
                                    }
                                  },
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text("Autentificare"),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterScreen()),
                            );
                          },
                          child: const Text('Nu ai cont? Înregistrează-te'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Opacity(
              opacity: 0.05,
              child: IconButton(
                onPressed: () => context.read<AuthService>().magicLogin(),
                icon: const Icon(Icons.auto_fix_high, size: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
