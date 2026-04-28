/// A Flutter package that detects device shakes, captures a screenshot, shows
/// a feedback dialog, and submits the result via a configurable callback.
///
/// ## Quick start
///
/// ```dart
/// // 1. Wrap your root widget with a RepaintBoundary using the package key:
/// RepaintBoundary(
///   key: ShakeFeedbackController.screenshotKey,
///   child: MyApp(),
/// )
///
/// // 2. Initialise after runApp, passing a context provider and submit handler:
/// ShakeFeedbackController.init(
///   contextProvider: () => navigatorKey.currentContext,
///   onSubmit: (submission, screenshot) async { /* send it */ },
/// );
///
/// // Or use any FeedbackService implementation:
/// ShakeFeedbackController.init(
///   contextProvider: () => navigatorKey.currentContext,
///   service: GitHubFeedbackService(
///     GitHubFeedbackConfig(token: '...', owner: 'my-org', repo: 'my-app'),
///   ),
/// );
///
/// // 3. Clean up when the app is done:
/// ShakeFeedbackController.dispose();
/// ```
library;

export 'src/feedback_dialog.dart';
export 'src/feedback_service.dart';
export 'src/feedback_submission.dart';
export 'src/github_feedback_service.dart';
export 'src/shake_feedback_controller.dart';
export 'src/shake_feedback_strings.dart';
