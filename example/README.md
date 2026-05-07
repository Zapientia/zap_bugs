# zap_bugs example app

Use this app to test `zap_bugs` end-to-end with:

- GitHub Issues integration
- shake-to-open feedback dialog

## Quick test

From the `example/` folder, run:

```sh
flutter run \
	--dart-define=SHAKE_FEEDBACK_ENABLED=true \
	--dart-define=GITHUB_FEEDBACK_TOKEN=ghp_xxxxxxxxxxxx
```

## What should happen

1. Launch the app on a physical device.
2. Shake the device.
3. The feedback dialog should appear.
4. Submit feedback.
5. A GitHub issue should be created in the configured `owner/repo` from `lib/main.dart`.

## Notes

- Use a GitHub fine-grained PAT with:
  - **Issues: Read and write**
  - **Contents: Read and write**
- Keep the token out of production builds.
