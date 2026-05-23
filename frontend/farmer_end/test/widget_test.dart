import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:farmer_end/main.dart';
import 'package:farmer_end/viewmodels/animal_viewmodel.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('Farm Management UI smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AnimalViewModel()),
        ],
        child: const MyApp(),
      ),
    );

    expect(find.text('Farm Management'), findsOneWidget);
    expect(find.text('View My Animals'), findsOneWidget);
    expect(find.text('Report Births/Deaths'), findsOneWidget);
  });
}
