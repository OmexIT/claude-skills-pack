# Mobile layer

These runners execute the project's own unit, widget, and instrumented suites. Unit and widget runs
are supporting evidence, not live verification: a flow counts as verified live only when an
integration or E2E test (or a recorded manual run) exercised it on a device or emulator against a
running backend. Use the repo's configured scripts and Gradle tasks when they exist.

| Platform | Unit / widget | On device or emulator |
|---|---|---|
| Flutter | `flutter test` | `flutter test integration_test/` |
| React Native | `npx jest --ci` | `npx detox test --configuration <repo's configuration>` |
| Android | `./gradlew testDebugUnitTest` | `./gradlew connectedDebugAndroidTest` |
| iOS | `xcodebuild test -scheme <scheme> -destination '<simulator>'` | same, with the UI test target |

Before a device run, confirm an emulator or simulator is booted (`adb devices`,
`xcrun simctl list devices booted`). If none is available, report the gap rather than skipping
silently.

Device tests follow the same locator priority as the web: accessibility labels and semantics first
(`Semantics`, `accessibilityLabel`, `contentDescription`), test IDs only as a fallback.

## Result skeleton

```
MOBILE - <platform>
  Unit/widget:   <passed>/<total> (supporting)
  Device/E2E:    <passed>/<total>; failing: <test names>
  Not run:       <suite> - <reason, for example no emulator>
```
