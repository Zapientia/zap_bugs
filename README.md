# shake_feedback

A Flutter package that detects device shakes, captures a screenshot, shows a configurable feedback dialog, and submits the result via **any backend** — including a built-in GitHub Issues integration.

---

## Features

- Shake detection (powered by [`shake`](https://pub.dev/packages/shake)) with tuneable sensitivity
- In-app screenshot capture at shake time
- Material feedback dialog — colours, typography, and shape come from the **ambient Theme** automatically
- Fully injectable strings — supply your own copy or translations via `ShakeFeedbackStrings`
- **`FeedbackService` abstract class** — implement once to send feedback to *any* destination (Jira, Linear, Slack, your own API…)
- Built-in **`GitHubFeedbackService`** — creates a GitHub issue with device info and an uploaded screenshot
- Convenience `service:` parameter on `ShakeFeedbackController.init`
- Web-safe: shake detection is silently skipped on non-mobile platforms

---

## Getting started

Add the package to `pubspec.yaml`:

```yaml
dependencies:
  shake_feedback:
    git:
      url: https://github.com/Zapientia/shake_feedback.git
      ref: main
  # or once published to pub.dev:
  # shake_feedback: ^0.1.0
```

---

## Usage

### 1. Wrap your root widget

```dart
// main.dart
final _navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    RepaintBoundary(
      key: ShakeFeedbackController.screenshotKey,
      child: MyApp(navigatorKey: _navigatorKey),
    ),
  );
}
```

### 2a. Use a raw callback

```dart
ShakeFeedbackController.init(
  contextProvider: () => _navigatorKey.currentContext,
  onSubmit: (submission, screenshot) async {
    // send wherever you like
  },
);
```

### 2b. Use the built-in GitHub integration

```dart
ShakeFeedbackController.init(
  contextProvider: () => _navigatorKey.currentContext,
  service: GitHubFeedbackService(
    GitHubFeedbackConfig(
      token: const String.fromEnvironment('GITHUB_FEEDBACK_TOKEN'),
      owner: 'my-org',
      repo: 'my-app',
    ),
  ),
);
```

### 2c. Implement your own backend

```dart
class LinearFeedbackService extends FeedbackService {
  @override
  Future<void> submit(
    FeedbackSubmission submission,
    Uint8List? screenshotBytes,
  ) async {
    // POST to Linear API, Jira, Slack webhook, etc.
  }
}

ShakeFeedbackController.init(
  contextProvider: () => _navigatorKey.currentContext,
  service: LinearFeedbackService(),
);
```

### 3. Customise strings / localise

```dart
ShakeFeedbackController.init(
  contextProvider: () => _navigatorKey.currentContext,
  service: myService,
  strings: ShakeFeedbackStrings(
    dialogTitle: 'Send us your feedback',
    submitButton: 'Submit',
  ),
);
```

### 4. Clean up

```dart
@override
void dispose() {
  ShakeFeedbackController.dispose();
  super.dispose();
}
```

---

## API reference

### `ShakeFeedbackController.init`

| Parameter | Type | Description |
|---|---|---|
| `contextProvider` | `BuildContext? Function()` | Returns the current context (typically `navigatorKey.currentContext`) |
| `onSubmit` | `OnFeedbackSubmit?` | Raw submit callback — takes precedence over `service` |
| `service` | `FeedbackService?` | Any `FeedbackService` implementation |
| `strings` | `ShakeFeedbackStrings` | Customise user-visible copy |
| `minimumShakeCount` | `int` | Default `1` |
| `shakeSlopTimeMS` | `int` | Default `500` |
| `shakeCountResetTime` | `int` | Default `3000` |
| `shakeThresholdGravity` | `double` | Default `2.7` |

### `FeedbackService`

Abstract class. Implement `submit(FeedbackSubmission, Uint8List?)` to integrate with any issue tracker.

### `GitHubFeedbackService`

Implements `FeedbackService`. Uploads a screenshot to the repository and creates a GitHub issue with device information.

---

## License

MIT
