import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:farmer_end/main.dart';
import 'package:farmer_end/services/auth_service.dart';
import 'package:farmer_end/viewmodels/animal_viewmodel.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('Farm Management login screen UI smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthService()),
          ChangeNotifierProvider(create: (_) => AnimalViewModel()),
        ],
        child: const MyApp(),
      ),
    );

    expect(find.text('Farmer Portal'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
    expect(find.text('Register Now'), findsOneWidget);
  });
}
