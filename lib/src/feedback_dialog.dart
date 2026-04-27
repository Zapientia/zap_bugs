import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'feedback_submission.dart';
import 'shake_feedback_strings.dart';

/// A self-contained feedback dialog that shows a description field and an
/// optional screenshot preview.
///
/// All colours, typography, and shape come from the ambient [Theme] so the
/// dialog automatically adapts to any app's design system.
///
/// Returns a [FeedbackSubmission] when the user taps submit, or `null` when
/// they dismiss / cancel.
class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({
    super.key,
    this.screenshotBytes,
    this.strings = const ShakeFeedbackStrings(),
  });

  final Uint8List? screenshotBytes;
  final ShakeFeedbackStrings strings;

  /// Convenience method to show the dialog and await the result.
  static Future<FeedbackSubmission?> show({
    required BuildContext context,
    Uint8List? screenshotBytes,
    ShakeFeedbackStrings strings = const ShakeFeedbackStrings(),
  }) {
    return showDialog<FeedbackSubmission>(
      context: context,
      barrierDismissible: true,
      builder: (_) => FeedbackDialog(
        screenshotBytes: screenshotBytes,
        strings: strings,
      ),
    );
  }

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSubmit => _controller.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      titleTextStyle: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      title: Text(widget.strings.dialogTitle),
      content: _buildContent(context),
      actions: _buildActions(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.strings.descriptionLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _controller,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: widget.strings.descriptionHint,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
            maxLines: 6,
            minLines: 4,
            textInputAction: TextInputAction.newline,
            onChanged: (_) => setState(() {}),
          ),
          if (widget.screenshotBytes != null) ...[
            const SizedBox(height: 12),
            Text(
              widget.strings.screenshotPreviewLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            _buildScreenshotPreview(context),
          ],
        ],
      ),
    );
  }

  Widget _buildScreenshotPreview(BuildContext context) {
    final shape = Theme.of(context).cardTheme.shape;
    final radius = shape is RoundedRectangleBorder
        ? shape.borderRadius as BorderRadius
        : BorderRadius.circular(8);
    return ClipRRect(
      borderRadius: radius,
      child: Image.memory(widget.screenshotBytes!, height: 140),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final theme = Theme.of(context);
    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        style: TextButton.styleFrom(
          foregroundColor: theme.colorScheme.onSurfaceVariant,
        ),
        child: Text(widget.strings.cancelButton),
      ),
      FilledButton(
        onPressed: _canSubmit
            ? () => Navigator.of(context).pop(
                  FeedbackSubmission(
                    description: _controller.text.trim(),
                  ),
                )
            : null,
        child: Text(widget.strings.submitButton),
      ),
    ];
  }
}
