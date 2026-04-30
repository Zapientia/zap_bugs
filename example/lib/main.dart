import 'package:flutter/material.dart';
import 'package:zap_bugs/zap_bugs.dart';

const _shakeFeedbackEnabled = bool.fromEnvironment(
  'SHAKE_FEEDBACK_ENABLED',
  defaultValue: true,
);
const _githubToken = String.fromEnvironment('GITHUB_FEEDBACK_TOKEN');

final _navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const ExampleBootstrap());
}

class ExampleBootstrap extends StatefulWidget {
  const ExampleBootstrap({super.key});

  @override
  State<ExampleBootstrap> createState() => _ExampleBootstrapState();
}

class _ExampleBootstrapState extends State<ExampleBootstrap> {
  @override
  void initState() {
    super.initState();

    if (!_shakeFeedbackEnabled) {
      return;
    }

    if (_githubToken.trim().isNotEmpty) {
      ZapBugsController.init(
        contextProvider: () => _navigatorKey.currentContext,
        service: GitHubFeedbackService(
          const GitHubFeedbackConfig(
            token: _githubToken,
            owner: 'my-org',
            repo: 'my-repo',
          ),
        ),
        stringsBuilder: (_) => const ZapBugsStrings(),
      );
      return;
    }

    ZapBugsController.init(
      contextProvider: () => _navigatorKey.currentContext,
      onSubmit: (submission, screenshotBytes) async {
        debugPrint(
          '[zap_bugs example] ${submission.description} '
          '(screenshot: ${screenshotBytes?.length ?? 0} bytes)',
        );
      },
    );
  }

  @override
  void dispose() {
    ZapBugsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: ZapBugsController.screenshotKey,
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        home: Scaffold(
          appBar: AppBar(title: const Text('zap_bugs example')),
          body: const Center(
            child: Text(
              'Shake the device to open the feedback dialog.\n\n'
              'Use --dart-define=SHAKE_FEEDBACK_ENABLED=true to enable.\n'
              'Use --dart-define=GITHUB_FEEDBACK_TOKEN=... for GitHub mode.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
