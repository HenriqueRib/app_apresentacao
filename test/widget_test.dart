import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:palestrante_de_sucesso/main.dart';

void main() {
  testWidgets('App should build successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
