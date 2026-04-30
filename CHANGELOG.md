## 0.1.0

- Initial release.
- Shake detection with tuneable sensitivity (powered by [`shake`](https://pub.dev/packages/shake)).
- In-app screenshot capture at shake time.
- Material feedback dialog — fully themed via `ThemeData`.
- Customisable copy and translations via `ZapBugsStrings`.
- `stringsBuilder` on `ZapBugsController.init` for lazy, context-based localization.
- `FeedbackService` abstract class for any backend.
- Built-in `GitHubFeedbackService` — creates a GitHub issue with device info and an optional screenshot.
- Web-safe: shake detection is silently skipped on Flutter Web.
- Release-friendly: non-web platforms are supported in release builds (use a feature flag to gate in production).
