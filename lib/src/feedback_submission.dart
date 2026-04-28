/// Data returned by the feedback dialog when the user submits.
class FeedbackSubmission {
  /// Creates a [FeedbackSubmission].
  const FeedbackSubmission({required this.description});

  /// The user's description of the bug or feedback.
  final String description;
}
