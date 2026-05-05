# zap_bugs

A Flutter package that detects device shakes, captures a screenshot, shows a feedback dialog, and submits the report — with a built-in GitHub Issues integration.

---

## Features

- Shake detection (powered by [`shake`](https://pub.dev/packages/shake)) with tuneable sensitivity
- In-app screenshot capture at shake time
- Material dialog — fully themed via `DialogTheme`, `InputDecorationTheme`, `TextButtonThemeData`, and `FilledButtonThemeData`
- Fully injectable strings — supply your own copy or translations via `ZapBugsStrings`
- Optional reporter name field that is persisted locally per device for future reports
- `FeedbackService` abstract class — implement once to send feedback anywhere (Jira, Linear, Slack, your own API…)
- Built-in `GitHubFeedbackService` — creates a GitHub issue with device info and an uploaded screenshot
- Web-safe: shake detection is silently skipped on Flutter Web
- Easy feature-flag rollout using `--dart-define`

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  zap_bugs: ^0.1.0
```

Then run:

```sh
flutter pub get
```

---

## GitHub Issues integration

### Step 1 — Create a Personal Access Token (PAT)

1. Go to **GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens**.
2. Under **Repository access**, select **Only select repositories** and choose the single repo your app reports to. Do not grant access to any other repository.
3. Grant only the minimum permissions needed on that repository:
   - **Contents** — Read and write _(required to upload screenshots as committed files)_
   - **Issues** — Read and write _(required to create issues)_
4. Copy the token — you will not be able to see it again.

> **Security:** Scope the token to a single repository, never to all repositories.  
> Never hard-code the token in source code or commit it to version control.  
> Pass it at build time using `--dart-define` or a secrets manager.

### Step 2 — Pass defines for non-production builds

Enable ZapBugs only in debug/internal testing builds. In production, do **not** pass the token or enable flag.

```sh
# Debug / local (enabled)
flutter run \
  --dart-define=SHAKE_FEEDBACK_ENABLED=true \
  --dart-define=GITHUB_FEEDBACK_TOKEN=ghp_xxxxxxxxxxxx

# Internal testing release build (enabled)
flutter build ipa \
  --dart-define=SHAKE_FEEDBACK_ENABLED=true \
  --dart-define=GITHUB_FEEDBACK_TOKEN=$GITHUB_FEEDBACK_TOKEN

# Production (feature OFF, token omitted)
flutter build ipa
```

For CI/CD, store `GITHUB_FEEDBACK_TOKEN` only in non-production pipelines and never inject it into production jobs.

### Step 3 — Wire up the package

> **Important:** Treat ZapBugs as a non-production feature. Keep it disabled in production by omitting `SHAKE_FEEDBACK_ENABLED` and `GITHUB_FEEDBACK_TOKEN`.

**`main.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:zap_bugs/zap_bugs.dart';

const _shakeFeedbackEnabled =
    bool.fromEnvironment('SHAKE_FEEDBACK_ENABLED', defaultValue: false);

final _navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    RepaintBoundary(
      key: ZapBugsController.screenshotKey, // required for screenshots
      child: MyApp(navigatorKey: _navigatorKey),
    ),
  );

  if (_shakeFeedbackEnabled) {
    final token = const String.fromEnvironment('GITHUB_FEEDBACK_TOKEN');
    if (token.trim().isEmpty) return;

    ZapBugsController.init(
      contextProvider: () => _navigatorKey.currentContext,
      service: GitHubFeedbackService(
        GitHubFeedbackConfig(
          token: token,
          owner: 'my-org',   // GitHub user or organisation
          repo: 'my-app',    // repository name
        ),
      ),
    );
  }
}
```

### Step 4 — Dispose in your app lifecycle (`State.dispose`)

```dart
@override
void dispose() {
  ZapBugsController.dispose();
  super.dispose();
}
```

That's it — shake the device, fill in the feedback form, and submit. An issue should be created in the configured GitHub repository with the feedback details and a screenshot attached.

### Production-safety checklist

- Do not pass `SHAKE_FEEDBACK_ENABLED=true` in production builds.
- Do not inject `GITHUB_FEEDBACK_TOKEN` in production CI/CD jobs.
- Use separate CI workflows (non-prod vs prod) so secrets cannot leak between lanes.

---

## `GitHubFeedbackConfig` reference

| Parameter         | Type           | Default                  | Description                                          |
| ----------------- | -------------- | ------------------------ | ---------------------------------------------------- |
| `token`           | `String`       | required                 | GitHub PAT with Contents + Issues write access       |
| `owner`           | `String`       | required                 | Repository owner (user or org)                       |
| `repo`            | `String`       | required                 | Repository name                                      |
| `screenshotsPath` | `String`       | `'feedback-screenshots'` | Path inside the repo where screenshots are committed |
| `labels`          | `List<String>` | `['feedback']`           | Labels applied to every created issue                |

---

## `ZapBugsController.init` reference

| Parameter               | Type                                     | Default  | Description                                                                                |
| ----------------------- | ---------------------------------------- | -------- | ------------------------------------------------------------------------------------------ |
| `contextProvider`       | `BuildContext? Function()`               | required | Returns the current context — typically `navigatorKey.currentContext`                      |
| `onSubmit`              | `OnFeedbackSubmit?`                      | `null`   | Raw submit callback; takes precedence over `service`                                       |
| `service`               | `FeedbackService?`                       | `null`   | Any `FeedbackService` implementation                                                       |
| `strings`               | `ZapBugsStrings?`                        | `null`   | Static copy override; falls back to built-in defaults when omitted                         |
| `stringsBuilder`        | `ZapBugsStrings Function(BuildContext)?` | `null`   | Lazy, context-aware strings (best for `AppLocalizations`); takes precedence over `strings` |
| `minimumShakeCount`     | `int`                                    | `1`      | Number of shakes required to trigger                                                       |
| `shakeSlopTimeMS`       | `int`                                    | `500`    | Minimum ms between shakes                                                                  |
| `shakeCountResetTime`   | `int`                                    | `3000`   | ms after which the shake count resets                                                      |
| `shakeThresholdGravity` | `double`                                 | `2.7`    | Sensitivity — lower values trigger more easily                                             |

---

## Localization patterns

Use either approach depending on your app architecture:

- Use `strings` when you have static copy (or non-context translation systems).
- Use `stringsBuilder` when your app uses context-based localization such as `AppLocalizations`.

```dart
ZapBugsController.init(
  contextProvider: () => _navigatorKey.currentContext,
  service: GitHubFeedbackService(config),
  stringsBuilder: (context) {
    final l10n = AppLocalizations.of(context)!;
    return ZapBugsStrings(
      dialogTitle: l10n.feedbackDialogTitle,
      descriptionLabel: l10n.feedbackDialogDescription,
      submitButton: l10n.feedbackSubmitButton,
      cancelButton: l10n.cancel,
      successMessage: l10n.feedbackSubmitSuccess,
      errorMessage: l10n.feedbackSubmitError,
    );
  },
);
```

Resolution precedence is:

1. `stringsBuilder(context)`
2. `strings`
3. built-in `ZapBugsStrings()` defaults

---

## Custom backend

Implement `FeedbackService` to send feedback anywhere:

```dart
class LinearFeedbackService extends FeedbackService {
  @override
  Future<void> submit(
    FeedbackSubmission submission,
    Uint8List? screenshotBytes,
  ) async {
    // `submission.reporter` contains the optional reporter name.
    // POST to Linear, Jira, Slack webhook, etc.
  }
}

ZapBugsController.init(
  contextProvider: () => _navigatorKey.currentContext,
  service: LinearFeedbackService(),
);
```

---

## Customising the dialog

Override these `ThemeData` properties in your app theme:

```dart
ThemeData(
  dialogTheme: DialogTheme(
    backgroundColor: Colors.grey[900],
    titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: Colors.white70),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(backgroundColor: Colors.deepPurple),
  ),
)
```

You can customize reporter field copy through `ZapBugsStrings`:

```dart
const ZapBugsStrings(
  reporterLabel: 'Reporter',
  reporterHint: 'Your name',
)
```

---

## Screenshot privacy

Screenshots automatically exclude sensitive system UI thanks to the `RepaintBoundary` architecture:

- **Status bar** — not captured (outside the app widget tree)
- **Notifications** — not captured (OS layer, not Flutter)
- **Keyboard** — not captured (system overlay)
- **Notification shade** — not captured (system layer)

Only your app's widget tree (inside the `RepaintBoundary`) is rendered to the screenshot. OS overlays and system UI exist at a different rendering layer and are never included. This is privacy-by-architecture — the tool simply doesn't have access to native system elements in the first place.

---

## Troubleshooting

### Shake is not detected

- Ensure `ZapBugsController.init(...)` is called.
- Confirm `SHAKE_FEEDBACK_ENABLED=true` is set for your non-production build.
- Try lowering `shakeThresholdGravity` if trigger sensitivity is too strict.

### Dialog never appears

- Make sure `contextProvider` returns a valid, mounted context (commonly `navigatorKey.currentContext`).
- Verify your app has a `MaterialApp`/`ScaffoldMessenger` in the widget tree.

### Screenshot is missing

- Ensure your app root is wrapped in a `RepaintBoundary` with `key: ZapBugsController.screenshotKey`.
- Screenshot capture failures are handled gracefully; feedback can still be submitted without an image.

### GitHub submission fails

- Validate PAT permissions (`Contents: Read and write`, `Issues: Read and write`).
- Ensure token, owner, and repo values are correct and token is not expired/revoked.
- Verify the token is only present in non-production environments.

---

## License

MIT
