import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:zap_bugs/src/feedback_submission.dart';
import 'package:zap_bugs/src/zap_bugs_strings.dart';

/// A self-contained feedback dialog that shows a description field and an
/// optional screenshot preview.
///
/// All colors, typography, shape, and button styles are resolved from the
/// ambient [Theme], so every team can fully customise the dialog's appearance
/// by providing their own [DialogTheme], [TextButtonThemeData],
/// [FilledButtonThemeData], and [InputDecorationTheme] inside [ThemeData].
///
/// Returns a [FeedbackSubmission] when the user taps submit, or `null` when
/// they dismiss / cancel.
class FeedbackDialog extends StatefulWidget {
  /// Creates a [FeedbackDialog].
  const FeedbackDialog({
    super.key,
    this.screenshotBytes,
    this.strings = const ZapBugsStrings(),
  });

  /// The PNG bytes of the screenshot to preview, or `null` if unavailable.
  final Uint8List? screenshotBytes;

  /// The strings used for labels and buttons in this dialog.
  final ZapBugsStrings strings;

  /// Convenience method to show the dialog and await the result.
  static Future<FeedbackSubmission?> show({
    required BuildContext context,
    Uint8List? screenshotBytes,
    ZapBugsStrings strings = const ZapBugsStrings(),
  }) {
    return showDialog<FeedbackSubmission>(
      context: context,
      barrierDismissible: true,
      builder:
          (_) => FeedbackDialog(
            screenshotBytes: screenshotBytes,
            strings: strings,
          ),
    );
  }

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  static const String _reporterPreferenceKey = 'zap_bugs.reporter';
  static const double _screenshotPreviewHeight = 140;
  static const int _reporterMaxLines = 1;
  static const int _descriptionMinLines = 4;
  static const int _descriptionMaxLines = 6;
  static const double _spacingMedium = 12;
  static const double _spacingSmall = 8;
  static const double _fallbackBorderRadius = 8;

  late final TextEditingController _reporterController;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _reporterController = TextEditingController();
    _controller = TextEditingController();
    _loadSavedReporter();
  }

  @override
  void dispose() {
    _reporterController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadSavedReporter() async {
    final prefs = await SharedPreferences.getInstance();
    final reporter = prefs.getString(_reporterPreferenceKey);

    if (!mounted || reporter == null || reporter.isEmpty) {
      return;
    }

    _reporterController.text = reporter;
    setState(() {});
  }

  Future<void> _saveReporter(String reporter) async {
    final prefs = await SharedPreferences.getInstance();
    if (reporter.isEmpty) {
      await prefs.remove(_reporterPreferenceKey);
      return;
    }
    await prefs.setString(_reporterPreferenceKey, reporter);
  }

  bool get _canSubmit => _controller.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.strings.dialogTitle),
      content: _buildContent(context),
      actions: _buildActions(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.strings.reporterLabel,
            style:
                Theme.of(context).dialogTheme.contentTextStyle ??
                Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: _spacingSmall),
          TextField(
            controller: _reporterController,
            decoration: InputDecoration(
              hintText: widget.strings.reporterHint,
            ),
            maxLines: _reporterMaxLines,
            minLines: _reporterMaxLines,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: _spacingMedium),
          Text(
            widget.strings.descriptionLabel,
            style:
                Theme.of(context).dialogTheme.contentTextStyle ??
                Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: _spacingMedium),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: widget.strings.descriptionHint,
            ),
            maxLines: _descriptionMaxLines,
            minLines: _descriptionMinLines,
            textInputAction: TextInputAction.newline,
            onChanged: (_) => setState(() {}),
          ),
          if (widget.screenshotBytes != null) ...[
            const SizedBox(height: _spacingMedium),
            Text(
              widget.strings.screenshotPreviewLabel,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: _spacingSmall),
            _buildScreenshotPreview(context),
          ],
        ],
      ),
    );
  }

  Widget _buildScreenshotPreview(BuildContext context) {
    final shape = Theme.of(context).cardTheme.shape;
    final BorderRadius radius;
    if (shape is RoundedRectangleBorder && shape.borderRadius is BorderRadius) {
      radius = shape.borderRadius as BorderRadius;
    } else {
      radius = BorderRadius.circular(_fallbackBorderRadius);
    }

    return ClipRRect(
      borderRadius: radius,
      child: Image.memory(
        widget.screenshotBytes!,
        height: _screenshotPreviewHeight,
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(widget.strings.cancelButton),
      ),
      FilledButton(
        onPressed:
            _canSubmit
                ? () async {
                  final reporter = _reporterController.text.trim();
                  await _saveReporter(reporter);
                  if (!context.mounted) {
                    return;
                  }
                  Navigator.of(context).pop(
                    FeedbackSubmission(
                      description: _controller.text.trim(),
                      reporter: reporter,
                    ),
                  );
                }
                : null,
        child: Text(widget.strings.submitButton),
      ),
    ];
  }
}
