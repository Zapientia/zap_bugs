import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zap_bugs/zap_bugs.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpDialog(
    WidgetTester tester, {
    Uint8List? screenshotBytes,
    ZapBugsStrings strings = const ZapBugsStrings(),
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FeedbackDialog(
            screenshotBytes: screenshotBytes,
            strings: strings,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('submit is disabled until description is non-empty', (
    tester,
  ) async {
    await pumpDialog(tester);

    final sendButton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(sendButton.onPressed, isNull);

    await tester.enterText(find.byType(TextField).at(1), 'Some feedback');
    await tester.pump();

    final updatedButton = tester.widget<FilledButton>(
      find.byType(FilledButton),
    );
    expect(updatedButton.onPressed, isNotNull);
  });

  testWidgets('shows screenshot label and preview when bytes are provided', (
    tester,
  ) async {
    const oneByOneTransparentPng = <int>[
      0x89,
      0x50,
      0x4E,
      0x47,
      0x0D,
      0x0A,
      0x1A,
      0x0A,
      0x00,
      0x00,
      0x00,
      0x0D,
      0x49,
      0x48,
      0x44,
      0x52,
      0x00,
      0x00,
      0x00,
      0x01,
      0x00,
      0x00,
      0x00,
      0x01,
      0x08,
      0x06,
      0x00,
      0x00,
      0x00,
      0x1F,
      0x15,
      0xC4,
      0x89,
      0x00,
      0x00,
      0x00,
      0x0D,
      0x49,
      0x44,
      0x41,
      0x54,
      0x78,
      0x9C,
      0x63,
      0x00,
      0x01,
      0x00,
      0x00,
      0x05,
      0x00,
      0x01,
      0x0D,
      0x0A,
      0x2D,
      0xB4,
      0x00,
      0x00,
      0x00,
      0x00,
      0x49,
      0x45,
      0x4E,
      0x44,
      0xAE,
      0x42,
      0x60,
      0x82,
    ];

    await pumpDialog(
      tester,
      screenshotBytes: Uint8List.fromList(oneByOneTransparentPng),
    );

    expect(find.text('Screenshot preview'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('uses custom strings', (tester) async {
    const strings = ZapBugsStrings(
      dialogTitle: 'Custom title',
      reporterLabel: 'Custom reporter label',
      reporterHint: 'Custom reporter hint',
      descriptionLabel: 'Custom label',
      submitButton: 'Ship it',
      cancelButton: 'Dismiss',
    );

    await pumpDialog(tester, strings: strings);

    expect(find.text('Custom title'), findsOneWidget);
    expect(find.text('Custom reporter label'), findsOneWidget);
    expect(find.text('Custom reporter hint'), findsOneWidget);
    expect(find.text('Custom label'), findsOneWidget);
    expect(find.text('Ship it'), findsOneWidget);
    expect(find.text('Dismiss'), findsOneWidget);
  });

  testWidgets('loads saved reporter name from local preferences', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'zap_bugs.reporter': 'Clara'});

    await pumpDialog(tester);

    expect(find.text('Clara'), findsOneWidget);
  });
}
