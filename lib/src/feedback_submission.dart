/// Data returned by the feedback dialog when the user submits.
class FeedbackSubmission {
  /// Creates a [FeedbackSubmission].
  const FeedbackSubmission({required this.description, this.reporter = ''});

  /// The user's description of the bug or feedback.
  final String description;

  /// Optional reporter name provided by the user.
  final String reporter;
}
