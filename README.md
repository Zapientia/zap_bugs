# shake_feedback

A Flutter package that detects device shakes, captures a screenshot, shows a feedback dialog, and submits the report — with a built-in GitHub Issues integration.

---

## Features

- Shake detection (powered by [`shake`](https://pub.dev/packages/shake)) with tuneable sensitivity
- In-app screenshot capture at shake time
- Material dialog — fully themed via `DialogTheme`, `InputDecorationTheme`, `TextButtonThemeData`, and `FilledButtonThemeData`
- Fully injectable strings — supply your own copy or translations via `ShakeFeedbackStrings`
- `FeedbackService` abstract class — implement once to send feedback anywhere (Jira, Linear, Slack, your own API…)
- Built-in `GitHubFeedbackService` — creates a GitHub issue with device info and an uploaded screenshot
- Web-safe: shake detection is silently skipped on non-mobile platforms
- Production-safe: completely inactive in release builds — the shake detector and its dependency are tree-shaken out of the production binary by the AOT compiler

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  shake_feedback: ^0.1.0
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

### Step 2 — Pass the token at build time

```sh
flutter run --dart-define=GITHUB_FEEDBACK_TOKEN=ghp_xxxxxxxxxxxx
```

For CI/CD, store the token as a secret and inject it the same way:

```sh
flutter build apk --dart-define=GITHUB_FEEDBACK_TOKEN=${{ secrets.GITHUB_FEEDBACK_TOKEN }}
```

### Step 3 — Wire up the package

> **Note:** `ShakeFeedbackController.init` is a no-op in release builds (`kReleaseMode == true`). The Dart AOT compiler eliminates the shake detector and its dependency from the production binary entirely — no overhead, no risk of accidental triggers in production.

**`main.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:shake_feedback/shake_feedback.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    RepaintBoundary(
      key: ShakeFeedbackController.screenshotKey, // required for screenshots
      child: MyApp(navigatorKey: _navigatorKey),
    ),
  );

  ShakeFeedbackController.init(
    contextProvider: () => _navigatorKey.currentContext,
    service: GitHubFeedbackService(
      GitHubFeedbackConfig(
        token: const String.fromEnvironment('GITHUB_FEEDBACK_TOKEN'),
        owner: 'my-org',   // GitHub user or organisation
        repo: 'my-app',    // repository name
      ),
    ),
  );
}
```

### Step 4 — Dispose when the app exits

```dart
AppLifecycleListener(
  onExitRequested: () async {
    ShakeFeedbackController.dispose();
    return AppExitResponse.exit;
  },
);
```

That's it — shake the device and a GitHub issue will be created automatically.

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

## `ShakeFeedbackController.init` reference

| Parameter               | Type                       | Default      | Description                                                           |
| ----------------------- | -------------------------- | ------------ | --------------------------------------------------------------------- |
| `contextProvider`       | `BuildContext? Function()` | required     | Returns the current context — typically `navigatorKey.currentContext` |
| `onSubmit`              | `OnFeedbackSubmit?`        | `null`       | Raw submit callback; takes precedence over `service`                  |
| `service`               | `FeedbackService?`         | `null`       | Any `FeedbackService` implementation                                  |
| `strings`               | `ShakeFeedbackStrings`     | default copy | Customise or translate all user-visible text                          |
| `minimumShakeCount`     | `int`                      | `1`          | Number of shakes required to trigger                                  |
| `shakeSlopTimeMS`       | `int`                      | `500`        | Minimum ms between shakes                                             |
| `shakeCountResetTime`   | `int`                      | `3000`       | ms after which the shake count resets                                 |
| `shakeThresholdGravity` | `double`                   | `2.7`        | Sensitivity — lower values trigger more easily                        |

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
    // POST to Linear, Jira, Slack webhook, etc.
  }
}

ShakeFeedbackController.init(
  contextProvider: () => _navigatorKey.currentContext,
  service: LinearFeedbackService(),
);
```

---

## Customising the dialog

Override any of these `ThemeData` properties in your app's theme:

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

---

## License

MIT
