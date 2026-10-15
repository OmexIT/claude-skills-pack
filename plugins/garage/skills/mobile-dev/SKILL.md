---
name: mobile-dev
description: "Use when the work is a mobile app in Flutter, React Native, Android (Kotlin), or iOS: architecture, state management, navigation, platform channels, widget or device tests, or app store readiness."
---

# Mobile development

Stack-aware guidance, patterns, and test strategy for Flutter, React Native, Android, and iOS.

## Inputs (ask only if missing)
- Platform and existing project files (`pubspec.yaml`, `package.json`, `build.gradle(.kts)`,
  `*.xcodeproj`); read the framework and library versions before recommending APIs
- State management, navigation, and DI already in use
- Feature description or spec, backend API and auth mechanism

## Existing apps keep their stack
Keep the app's proven navigation, state, DI, and secure-storage choices unless a measured problem
justifies migration. The defaults below are for greenfield choices only.

## Money and offline (all platforms)
- Money is decimal end to end: parse API amounts into a decimal type (Dart `decimal`, a JS decimal
  library or minor-unit integers, Kotlin `BigDecimal`, Swift `Decimal`), never `double`/`float`.
- Cached money reads (balances, limits, prices) are visibly stale and non-authoritative: show when
  they were fetched and refresh before any decision that depends on them.
- Never queue offline money mutations unless the product has a reviewed durable idempotency,
  ordering, and reconciliation design. Without it, money actions require connectivity, and an
  unknown result (timeout, app killed mid-request) fails closed: show "pending, checking" and
  reconcile with the server, never retry blindly or assume failure.
- Other offline writes: decide per feature whether a local queue is worth it; define conflict
  resolution before building one. "Show an error when offline" is a valid answer.

## Flutter
- Feature-first directories with presentation, domain, data layers where the feature has real logic.
- Greenfield state and routing: Riverpod and GoRouter; `setState` is fine for local widget state.
- Platform interop: MethodChannel, EventChannel, or Pigeon for typed interfaces; handle `PlatformException`.
- Tests: widget tests for UI logic, `integration_test/` for flows, golden tests only where visual
  regressions have bitten.
- Flavors only for real environment differences; `--dart-define` for build-time constants.
- Performance: `const` constructors, `ListView.builder` for long lists, profile in DevTools.

## React Native
- Feature directories; platform files (`.ios.tsx`, `.android.tsx`) only where behavior differs.
- Server state through a query cache (for example React Query); keep state local before adding a
  shared store.
- Secrets and tokens in platform-backed secure storage (Keychain/Keystore wrappers), never
  AsyncStorage.
- Navigation: React Navigation with typed routes, at the version the project already uses.
- New Architecture: Turbo Modules or the project's existing native-module approach, with TypeScript
  types for native interfaces.
- Tests: Jest with React Native Testing Library; Detox or the project's E2E runner for flows.
- Performance: Hermes, `FlatList` virtualization, profile with React Native DevTools.

## Android (Kotlin)
- MVVM with Compose, ViewModel exposing StateFlow, `SavedStateHandle` for process death.
- Greenfield: Hilt and DataStore. Navigation Compose with typed routes; single activity.
- Tests: JUnit and MockK for logic, Compose testing for UI, Robolectric for fast JVM UI tests.
- Release: R8 rules, per-variant signing; Baseline Profiles when startup is measured slow.

## iOS (Swift)
- SwiftUI or UIKit as the project already uses; observable view models; Keychain for secrets.
- Tests: XCTest for logic, XCUITest for flows.

## Cross-cutting
- Accessibility: every interactive element has an accessible name and role (`Semantics`,
  `accessibilityLabel`, `contentDescription`); touch targets at least 48dp Android, 44pt iOS. Tests
  find elements by these; test IDs only when semantics are insufficient.
- Deep links (Universal Links, App Links): test with `adb shell am start` and `xcrun simctl openurl`.
- Push: foreground versus background handling, Android notification channels.
- Loading, error, empty, and offline states for every async screen.
- App store: privacy manifest and data-safety forms, review guidelines, version and build numbers.

## Anti-patterns to flag
- `double` for money; queued offline money mutations without the reviewed design; cached balances
  shown as current
- Secrets or tokens in plain storage
- Blocking the UI thread; platform code in shared business logic
- Controls without accessible names

## Workflow context
- Follows `design-doc`, `api-design`, `flow-map`; related: `ux-review` (mobile UX), `ui-design` (Stitch mobile layouts), `infra-design` (mobile CI).
- Feeds `test-plan` (mobile test cases) and `verify-impl` (device verification).

## Output contract
```yaml
produces:
  - type: "mobile-guidance"
    format: "markdown"
    path: "claudedocs/<feature>-mobile-dev.md"
    sections: [architecture, state_management, navigation, testing, platform_specific, test_commands, build_commands]
    handoff: "Write claudedocs/handoff-mobile-dev-<timestamp>.yaml - suggest: spec-to-impl, test-plan, verify-impl"
```
