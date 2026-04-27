/// All user-visible strings shown by `shake_feedback` widgets.
///
/// Override any field to provide your own copy or translations. Every field has
/// a sensible English default so callers only need to supply what they want to
/// customise.
class ShakeFeedbackStrings {
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

  final String dialogTitle;
  final String descriptionLabel;
  final String descriptionHint;
  final String screenshotPreviewLabel;
  final String submitButton;
  final String cancelButton;
  final String successMessage;
  final String errorMessage;
}
