import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import 'feedback_service.dart';
import 'feedback_submission.dart';
import 'shake_feedback_controller.dart';

/// Configuration for the built-in GitHub issue submitter.
class GitHubFeedbackConfig {
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
///
/// ### Usage with [ShakeFeedbackController]
/// ```dart
/// final githubService = GitHubFeedbackService(
///   GitHubFeedbackConfig(
///     token: const String.fromEnvironment('GITHUB_FEEDBACK_TOKEN'),
///     owner: 'my-org',
///     repo: 'my-app',
///   ),
/// );
///
/// ShakeFeedbackController.init(
///   contextProvider: () => navigatorKey.currentContext,
///   service: githubService,
/// );
/// ```
class GitHubFeedbackService extends FeedbackService {
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
      throw Exception('[shake_feedback] Missing GitHub feedback token.');
    }

    final deviceInfo = await _collectDeviceInfo();
    String? screenshotUrl;

    if (screenshotBytes != null) {
      screenshotUrl = await _uploadScreenshot(screenshotBytes);
    }

    await _createIssue(
      title: ShakeFeedbackController.buildIssueTitleFromDescription(
        submission.description,
      ),
      description: submission.description,
      deviceInfo: deviceInfo,
      screenshotUrl: screenshotUrl,
    );
  }

  Future<String?> _uploadScreenshot(Uint8List bytes) async {
    final filename =
        'screenshot-${DateTime.now().millisecondsSinceEpoch}.png';
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

    if (response.statusCode == 201) {
      return 'https://github.com/${_config.owner}/${_config.repo}'
          '/blob/main/${_config.screenshotsPath}/$filename?raw=true';
    }

    return null;
  }

  Future<void> _createIssue({
    required String title,
    required String description,
    required String deviceInfo,
    String? screenshotUrl,
  }) async {
    final screenshotSection = screenshotUrl != null
        ? '\n\n## Screenshot\n![Screenshot]($screenshotUrl)'
        : '';

    final body = '''
## Description
$description

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
        '[shake_feedback] Failed to create GitHub issue: '
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
      rows.add('| Platform | ${Platform.operatingSystem} |');
      rows.add('| OS version | ${Platform.operatingSystemVersion} |');
    }

    return rows.join('\n');
  }

  Map<String, String> get _headers => {
        'Authorization': 'Bearer ${_config.token}',
        'Accept': 'application/vnd.github+json',
        'Content-Type': 'application/json',
        'X-GitHub-Api-Version': '2022-11-28',
      };
}
