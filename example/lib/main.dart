import 'package:flutter/material.dart';
import 'package:zap_bugs/zap_bugs.dart';

import 'app_theme.dart';

// Enable with:
// --dart-define=SHAKE_FEEDBACK_ENABLED=true
// --dart-define=GITHUB_FEEDBACK_TOKEN=ghp_xxx
// Keep both defines out of production builds.
const _shakeFeedbackEnabled = bool.fromEnvironment(
  'SHAKE_FEEDBACK_ENABLED',
  defaultValue: false,
);

final _navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    RepaintBoundary(
      key: ZapBugsController.screenshotKey, // required for screenshots
      child: _ExampleApp(navigatorKey: _navigatorKey),
    ),
  );

  if (_shakeFeedbackEnabled) {
    final githubToken = const String.fromEnvironment('GITHUB_FEEDBACK_TOKEN');

    if (githubToken.trim().isEmpty) {
      debugPrint(
        '[zap_bugs example] Missing GITHUB_FEEDBACK_TOKEN. '
        'ZapBugs disabled for this run.',
      );
      return;
    }

    ZapBugsController.init(
      contextProvider: () => _navigatorKey.currentContext,
      service: GitHubFeedbackService(
        GitHubFeedbackConfig(
          token: githubToken,
          owner: 'my-org',
          repo: 'my-app',
        ),
      ),
    );
  }
}

class _ExampleApp extends StatefulWidget {
  const _ExampleApp({required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<_ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<_ExampleApp> {
  @override
  void dispose() {
    ZapBugsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: widget.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'ZapBugs Example',
      // ZapBugs reads DialogTheme, button themes, input decoration, text
      // theme, and colors from the ambient theme — style it like your own app.
      theme: buildAppTheme(),
      home: const WellnessHomeScreen(),
    );
  }
}

class WellnessHomeScreen extends StatelessWidget {
  const WellnessHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Header(),
              const SizedBox(height: 28),
              const _SectionTitle(
                title: 'Wellness',
                subtitle: 'Track your daily progress',
              ),
              const SizedBox(height: 20),
              const _ActivityCard(),
              const SizedBox(height: 16),
              const _HeartRateCard(),
              const SizedBox(height: 24),
              const _ReportBugTile(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tokens = Theme.of(context).extension<ExampleThemeTokens>()!;

    return Row(
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: colors.onSurface,
        ),
        const SizedBox(width: 4),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: colors.primary, width: 2),
            color: colors.surface,
          ),
          alignment: Alignment.center,
          child: Icon(Icons.person, color: tokens.primarySoft, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, Clara',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Welcome back',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
          color: colors.onSurface,
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tokens = Theme.of(context).extension<ExampleThemeTokens>()!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Activity",
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '4,350',
                    style: textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Steps',
                    style: textTheme.bodyMedium?.copyWith(
                      color: tokens.primarySoft,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Goal',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '10,000',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 90,
              height: 90,
              child: CustomPaint(
                painter: _BarChartPainter(color: colors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  const _BarChartPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const heights = [0.4, 0.55, 0.35, 0.7, 0.5, 0.85, 0.6];
    final barWidth = size.width / (heights.length * 1.6);
    final gap = barWidth * 0.6;
    final paint = Paint()..color = color;
    final paintSoft = Paint()..color = color.withValues(alpha: 0.35);

    for (var i = 0; i < heights.length; i++) {
      final h = size.height * heights[i];
      final x = i * (barWidth + gap);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, size.height - h, barWidth, h),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect, i == 5 ? paint : paintSoft);
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _HeartRateCard extends StatelessWidget {
  const _HeartRateCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tokens = Theme.of(context).extension<ExampleThemeTokens>()!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Heart Rate',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '72',
                        style: textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          'BPM',
                          style: textTheme.bodySmall?.copyWith(
                            color: tokens.primarySoft,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 110,
              height: 50,
              child: CustomPaint(
                painter: _HeartLinePainter(color: colors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeartLinePainter extends CustomPainter {
  const _HeartLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final mid = size.height / 2;
    path.moveTo(0, mid);
    path.lineTo(size.width * 0.25, mid);
    path.lineTo(size.width * 0.32, mid - size.height * 0.15);
    path.lineTo(size.width * 0.40, mid + size.height * 0.4);
    path.lineTo(size.width * 0.48, mid - size.height * 0.45);
    path.lineTo(size.width * 0.56, mid + size.height * 0.15);
    path.lineTo(size.width * 0.65, mid);
    path.lineTo(size.width, mid);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HeartLinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _ReportBugTile extends StatelessWidget {
  const _ReportBugTile();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.primary.withValues(alpha: 0.4)),
        gradient: LinearGradient(
          colors: [
            colors.primary.withValues(alpha: 0.18),
            colors.primary.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.bolt_rounded,
                color: colors.onPrimary,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shake to report a bug',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Shake your device to report a bug',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.secondary),
          ],
        ),
      ),
    );
  }
}
