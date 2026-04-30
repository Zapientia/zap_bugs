import 'dart:typed_data';

import 'package:zap_bugs/src/feedback_submission.dart';

/// Contract for any backend that receives shake-to-report feedback.
///
/// Implement this class to send feedback to your own issue tracker, crash
/// reporting tool, Slack webhook, or any other destination.
///
/// ## Example — custom HTTP backend
/// ```dart
/// class MyApiService extends FeedbackService {
///   @override
///   Future<void> submit(
///     FeedbackSubmission submission,
///     Uint8List? screenshotBytes,
///   ) async {
///     await http.post(
///       Uri.parse('https://api.example.com/feedback'),
///       body: jsonEncode({'message': submission.description}),
///     );
///   }
/// }
/// ```
abstract class FeedbackService {
  /// Creates a [FeedbackService].
  const FeedbackService();

  /// Called after the user fills in and submits the feedback dialog.
  ///
  /// Throw any exception to trigger the error snack-bar inside
  /// [ZapBugsController].
  Future<void> submit(
    FeedbackSubmission submission,
    Uint8List? screenshotBytes,
  );
}
