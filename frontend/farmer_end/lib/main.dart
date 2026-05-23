import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/animal_viewmodel.dart';
import 'services/auth_service.dart';
import 'views/home_view.dart';
import 'views/login_view.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProxyProvider<AuthService, AnimalViewModel>(
          create: (_) => AnimalViewModel(),
          update: (_, authService, animalViewModel) {
            return animalViewModel!..updateAuth(authService);
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farmer Animal Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: Consumer<AuthService>(
        builder: (context, authService, _) {
          return authService.isAuthenticated ? const HomeView() : const LoginView();
        },
      ),
    );
  }
}
