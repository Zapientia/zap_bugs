/// All user-visible strings shown by `shake_feedback` widgets.
///
/// Override any field to provide your own copy or translations. Every field has
/// a sensible English default so callers only need to supply what they want to
/// customise.
class ShakeFeedbackStrings {
  /// Creates a [ShakeFeedbackStrings] instance; override only the fields you need.
  const ShakeFeedbackStrings({
    this.dialogTitle = 'Report a bug or send feedback',
    this.descriptionLabel = 'Description',
    this.descriptionHint = 'Describe the bug or your feedback',
    this.screenshotPreviewLabel = 'Screenshot preview',
    this.submitButton = 'Send',
    this.cancelButton = 'Cancel',
    this.successMessage = 'Feedback sent successfully.',
    this.errorMessage = 'We could not send your feedback. Please try again.',
  });

  /// Title shown at the top of the feedback dialog.
  final String dialogTitle;

  /// Label above the description text field.
  final String descriptionLabel;

  /// Placeholder text inside the description field.
  final String descriptionHint;

  /// Label shown above the screenshot thumbnail.
  final String screenshotPreviewLabel;

  /// Text on the submit/send button.
  final String submitButton;

  /// Text on the cancel button.
  final String cancelButton;

  /// Snack-bar message shown after successful submission.
  final String successMessage;

  /// Snack-bar message shown when submission fails.
  final String errorMessage;
}
