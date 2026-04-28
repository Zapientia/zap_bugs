import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:shake/shake.dart';

import 'package:zap_bugs/src/feedback_dialog.dart';
import 'package:zap_bugs/src/feedback_service.dart';
import 'package:zap_bugs/src/feedback_submission.dart';
import 'package:zap_bugs/src/zap_bugs_strings.dart';

/// Signature for the callback invoked after the user submits feedback.
///
/// Receives the user's [submission] and, if available, the PNG [screenshotBytes].
/// Throw any exception to trigger the error snack-bar.
typedef OnFeedbackSubmit =
    Future<void> Function(
      FeedbackSubmission submission,
      Uint8List? screenshotBytes,
    );

/// Controls shake-to-report behaviour for a Flutter application.
///
/// ### Minimal setup
/// ```dart
/// // In main.dart — wrap your root widget:
/// RepaintBoundary(
///   key: ZapBugsController.screenshotKey,
///   child: MyApp(),
/// )
///
/// // After runApp — using a raw callback:
/// ZapBugsController.init(
///   contextProvider: () => navigatorKey.currentContext,
///   onSubmit: (submission, screenshot) async {
///     // send wherever you like
///   },
/// );
///
/// // Or use any FeedbackService implementation:
/// ZapBugsController.init(
///   contextProvider: () => navigatorKey.currentContext,
///   service: GitHubFeedbackService(config),
/// );
/// ```
///
/// Call [dispose] when your app shuts down (e.g. in `AppLifecycleListener`).
class ZapBugsController {
  ZapBugsController._();

  // ---------------------------------------------------------------------------
  // Public surface
  // ---------------------------------------------------------------------------

  /// A [GlobalKey] that must be placed on a [RepaintBoundary] wrapping the
  /// root widget so that screenshots can be captured.
  static final GlobalKey screenshotKey = GlobalKey();

  /// Starts listening for shakes.
  ///
  /// **No-op on web** (`kIsWeb == true`). On all other platforms — including
  /// release builds — the detector starts as long as this method is called.
  /// Gate the call yourself using a `--dart-define` flag so that TestFlight,
  /// Google Play internal testing, and other pre-production release builds
  /// still receive shake feedback while production builds do not.
  ///
  /// Provide either [onSubmit] **or** [service] — if both are supplied,
  /// [onSubmit] takes precedence.
  ///
  /// - [contextProvider] — returns the current [BuildContext] used to show the
  ///   dialog and snack-bars.  Typically `navigatorKey.currentContext`.
  /// - [onSubmit] — raw async callback invoked with the filled-in
  ///   [FeedbackSubmission] (and optional screenshot bytes).  Throw to trigger
  ///   an error snack-bar.
  /// - [service] — a [FeedbackService] instance (e.g. [GitHubFeedbackService]).
  ///   Ignored when [onSubmit] is provided.
  /// - [strings] — customise all user-visible copy (or provide translations).
  /// - Shake tuning parameters: [minimumShakeCount], [shakeSlopTimeMS],
  ///   [shakeCountResetTime], [shakeThresholdGravity].
  static void init({
    required BuildContext? Function() contextProvider,
    OnFeedbackSubmit? onSubmit,
    FeedbackService? service,
    ZapBugsStrings strings = const ZapBugsStrings(),
    int minimumShakeCount = 1,
    int shakeSlopTimeMS = 500,
    int shakeCountResetTime = 3000,
    double shakeThresholdGravity = 2.7,
  }) {
    assert(
      onSubmit != null || service != null,
      'Provide either onSubmit or service.',
    );

    if (kIsWeb) return;

    _contextProvider = contextProvider;
    _onSubmit =
        onSubmit ??
        (submission, screenshot) => service!.submit(submission, screenshot);
    _strings = strings;

    runZonedGuarded(() {
      _detector = ShakeDetector.autoStart(
        onPhoneShake: (_) => _onShake(),
        minimumShakeCount: minimumShakeCount,
        shakeSlopTimeMS: shakeSlopTimeMS,
        shakeCountResetTime: shakeCountResetTime,
        shakeThresholdGravity: shakeThresholdGravity,
      );
    }, (e, _) => debugPrint('[ZapBugs] ShakeDetector unavailable: $e'));
  }

  /// Stops the shake detector. Call this when your app is being disposed.
  static void dispose() {
    _detector?.stopListening();
    _detector = null;
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  static ShakeDetector? _detector;
  static bool _isDialogOpen = false;
  static BuildContext? Function() _contextProvider = () => null;
  static OnFeedbackSubmit _onSubmit = (_, __) async {};
  static ZapBugsStrings _strings = const ZapBugsStrings();

  static const double _screenshotPixelRatio = 2.0;

  static Future<void> _onShake() async {
    if (_isDialogOpen) return;

    final context = _contextProvider();
    if (context == null) return;

    _isDialogOpen = true;
    final screenshot = await _captureScreenshot();

    if (!context.mounted) {
      _isDialogOpen = false;
      return;
    }

    final submission = await FeedbackDialog.show(
      context: context,
      screenshotBytes: screenshot,
      strings: _strings,
    );

    if (submission != null && context.mounted) {
      try {
        await _onSubmit(submission, screenshot);

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(_strings.successMessage)));
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(_strings.errorMessage)));
        }
      }
    }

    _isDialogOpen = false;
  }

  static Future<Uint8List?> _captureScreenshot() async {
    try {
      await _waitForNextFrame();

      final renderObject = screenshotKey.currentContext?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) return null;

      final ui.Image image = await renderObject.toImage(
        pixelRatio: _screenshotPixelRatio,
      );
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  static Future<void> _waitForNextFrame() async {
    await Future.microtask(() {});
    final completer = Completer<void>();
    SchedulerBinding.instance.scheduleFrame();
    WidgetsBinding.instance.addPostFrameCallback((_) => completer.complete());
    await completer.future;
  }
}
