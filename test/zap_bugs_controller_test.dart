import 'package:flutter_test/flutter_test.dart';
import 'package:zap_bugs/zap_bugs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'init throws assertion error when neither onSubmit nor service is set',
    () {
      expect(
        () => ZapBugsController.init(contextProvider: () => null),
        throwsA(isA<AssertionError>()),
      );
    },
  );

  test('init and dispose with onSubmit do not throw', () {
    expect(() {
      ZapBugsController.init(
        contextProvider: () => null,
        onSubmit: (_, __) async {},
      );
      ZapBugsController.dispose();
    }, returnsNormally);
  });

  test('ZapBugsStrings defaults stay non-empty', () {
    const strings = ZapBugsStrings();

    expect(strings.dialogTitle, isNotEmpty);
    expect(strings.descriptionLabel, isNotEmpty);
    expect(strings.descriptionHint, isNotEmpty);
    expect(strings.screenshotPreviewLabel, isNotEmpty);
    expect(strings.submitButton, isNotEmpty);
    expect(strings.cancelButton, isNotEmpty);
    expect(strings.successMessage, isNotEmpty);
    expect(strings.errorMessage, isNotEmpty);
  });
}
