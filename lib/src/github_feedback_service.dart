import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import 'package:zap_bugs/src/feedback_service.dart';
import 'package:zap_bugs/src/feedback_submission.dart';

/// Configuration for the built-in GitHub issue submitter.
class GitHubFeedbackConfig {
  /// Creates a [GitHubFeedbackConfig].
  const GitHubFeedbackConfig({
    required this.token,
    required this.owner,
    required this.repo,
    this.screenshotsPath = 'feedback-screenshots',
    this.labels = const ['feedback'],
  });

  /// A GitHub personal access token (or fine-grained token) with
  /// `repo` scope so the service can upload screenshots and create issues.
  ///
  /// Keep this out of source control — pass it via an environment variable or
  /// a secrets manager and supply it at runtime.
  final String token;

  /// GitHub repository owner (user or organisation).
  final String owner;

  /// GitHub repository name.
  final String repo;

  /// Path inside the repository where screenshot files will be committed.
  final String screenshotsPath;

  /// Labels applied to every created issue.
  final List<String> labels;
}

/// A ready-made [FeedbackService] implementation that creates a GitHub issue
/// and (optionally) uploads a screenshot to the repository.
class GitHubFeedbackService extends FeedbackService {
  /// Creates a [GitHubFeedbackService] with the given [config].
  GitHubFeedbackService(this._config);

  static const String _apiBase = 'https://api.github.com';

  final GitHubFeedbackConfig _config;

  /// Implements [FeedbackService.submit].
  @override
  Future<void> submit(
    FeedbackSubmission submission,
    Uint8List? screenshotBytes,
  ) async {
    if (_config.token.trim().isEmpty) {
      throw Exception('[zap_bugs] Missing GitHub feedback token.');
    }

    final deviceInfo = await _collectDeviceInfo();
    String? screenshotUrl;

    if (screenshotBytes != null) {
      screenshotUrl = await _uploadScreenshot(screenshotBytes);
    }

    await _createIssue(
      title: _buildIssueTitle(submission.description),
      description: submission.description,
      reporter: submission.reporter,
      deviceInfo: deviceInfo,
      screenshotUrl: screenshotUrl,
    );
  }

  Future<String?> _uploadScreenshot(Uint8List bytes) async {
    final filename = 'screenshot-${DateTime.now().millisecondsSinceEpoch}.png';
    final url = Uri.parse(
      '$_apiBase/repos/${_config.owner}/${_config.repo}'
      '/contents/${_config.screenshotsPath}/$filename',
    );

    final response = await http.put(
      url,
      headers: _headers,
      body: jsonEncode({
        'message': 'feedback: add screenshot $filename',
        'content': base64Encode(bytes),
      }),
    );

    if (response.statusCode != 201) {
      return null;
    }

    // Prefer the raw download URL returned by GitHub so the link points at the
    // correct branch (works regardless of whether the default branch is `main`,
    // `master`, or anything else).
    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final content = decoded['content'];
      if (content is Map<String, dynamic>) {
        final downloadUrl = content['download_url'];
        if (downloadUrl is String && downloadUrl.isNotEmpty) {
          return downloadUrl;
        }
      }
    } catch (_) {
      // Fall through to the constructed URL below.
    }

    return 'https://github.com/${_config.owner}/${_config.repo}'
        '/blob/HEAD/${_config.screenshotsPath}/$filename?raw=true';
  }

  Future<void> _createIssue({
    required String title,
    required String description,
    required String reporter,
    required String deviceInfo,
    String? screenshotUrl,
  }) async {
    final reporterSection =
        reporter.trim().isEmpty ? '' : '\n\n## Reporter\n${reporter.trim()}';
    final screenshotSection =
        screenshotUrl != null
            ? '\n\n## Screenshot\n![Screenshot]($screenshotUrl)'
            : '';

    final body = '''
## Description
$description
$reporterSection

## Device Info
$deviceInfo$screenshotSection
''';

    final url = Uri.parse(
      '$_apiBase/repos/${_config.owner}/${_config.repo}/issues',
    );

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'body': body,
        'labels': _config.labels,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(
        '[zap_bugs] Failed to create GitHub issue: '
        '${response.statusCode} ${response.body}',
      );
    }
  }

  Future<String> _collectDeviceInfo() async {
    final info = await PackageInfo.fromPlatform();
    final rows = <String>[
      '| Field | Value |',
      '|---|---|',
      '| App version | ${info.version} (${info.buildNumber}) |',
    ];

    if (!kIsWeb) {
      rows.add('| Platform | ${defaultTargetPlatform.name} |');
    }

    return rows.join('\n');
  }

  Map<String, String> get _headers => {
    'Authorization': 'Bearer ${_config.token}',
    'Accept': 'application/vnd.github+json',
    'Content-Type': 'application/json',
    'X-GitHub-Api-Version': '2022-11-28',
  };

  static const int _issueTitleMaxLength = 80;

  static String _buildIssueTitle(String description) {
    final normalized = description.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.isEmpty) return 'Feedback report';
    if (normalized.length <= _issueTitleMaxLength) return normalized;
    return '${normalized.substring(0, _issueTitleMaxLength - 1)}\u2026';
  }
}
