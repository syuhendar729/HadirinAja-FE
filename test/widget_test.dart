import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hadirinaja_fe/pages/login_page.dart';

void main() {
  testWidgets('Login page renders app entry point', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    expect(find.text('HadirinAja'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
